import Foundation

/// PostgREST client.
public final class PostgrestClient {

  /// The configuration struct for the PostgREST client.
  public struct Configuration {
    public var url: URL
    public var schema: String?
    public var headers: [String: String]
    public var session: URLSession
    public var encoder: JSONEncoder
    public var decoder: JSONDecoder

    /// Initializes a new configuration for the PostgREST client.
    /// - Parameters:
    ///   - url: The URL of the PostgREST server.
    ///   - schema: The schema to use.
    ///   - headers: The headers to include in requests.
    ///   - session: The URLSession to use for requests.
    ///   - encoder: The JSONEncoder to use for encoding.
    ///   - decoder: The JSONDecoder to use for decoding.
    public init(
      url: URL,
      schema: String? = nil,
      headers: [String: String] = [:],
      session: URLSession = .shared,
      encoder: JSONEncoder = .postgrest,
      decoder: JSONDecoder = .postgrest
    ) {
      self.url = url
      self.schema = schema
      self.headers = headers
      self.session = session
      self.encoder = encoder
      self.decoder = decoder
    }
  }

  private let lock = NSLock()
  public private(set) var configuration: Configuration

  /// Creates a PostgREST client with the specified configuration.
  /// - Parameter configuration: The configuration for the client.
  public init(configuration: Configuration) {
    var configuration = configuration
    configuration.headers["X-Client-Info"] = "postgrest-swift/\(version)"
    self.configuration = configuration
  }

  /// Creates a PostgREST client with the specified parameters.
  /// - Parameters:
  ///   - url: The URL of the PostgREST server.
  ///   - schema: The schema to use.
  ///   - headers: The headers to include in requests.
  ///   - session: The URLSession to use for requests.
  ///   - encoder: The JSONEncoder to use for encoding.
  ///   - decoder: The JSONDecoder to use for decoding.
  public convenience init(
    url: URL,
    schema: String? = nil,
    headers: [String: String] = [:],
    session: URLSession = .shared,
    encoder: JSONEncoder = .postgrest,
    decoder: JSONDecoder = .postgrest
  ) {
    self.init(
      configuration: Configuration(
        url: url,
        schema: schema,
        headers: headers,
        session: session,
        encoder: encoder,
        decoder: decoder
      )
    )
  }

  /// Sets the authorization token for the client.
  /// - Parameter token: The authorization token.
  /// - Returns: The PostgrestClient instance.
  @discardableResult
  public func setAuth(_ token: String?) -> PostgrestClient {
    lock.lock()
    defer { lock.unlock() }

    if let token {
      configuration.headers["Authorization"] = "Bearer \(token)"
    } else {
      configuration.headers.removeValue(forKey: "Authorization")
    }
    return self
  }

  /// Performs a query on a table or a view.
  /// - Parameter table: The table or view name to query.
  /// - Returns: A PostgrestQueryBuilder instance.
  public func from(_ table: String) -> PostgrestQueryBuilder {
    lock.lock()
    defer { lock.unlock() }
    return PostgrestQueryBuilder(
      configuration: configuration,
      url: configuration.url.appendingPathComponent(table),
      queryParams: [],
      headers: configuration.headers,
      method: "GET",
      body: nil
    )
  }

  /// Performs a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count: Count algorithm to use to count rows returned by the function.
  ///             Only applicable for set-returning functions.
  /// - Returns: A PostgrestTransformBuilder instance.
  /// - Throws: An error if the function call fails.
  public func rpc<U: Encodable>(
    fn: String,
    params: U,
    count: CountOption? = nil
  ) throws -> PostgrestTransformBuilder {
    lock.lock()
    defer { lock.unlock() }
    return try PostgrestRpcBuilder(
      configuration: configuration,
      url: configuration.url.appendingPathComponent("rpc").appendingPathComponent(fn),
      queryParams: [],
      headers: configuration.headers,
      method: "POST",
      body: nil
    ).rpc(params: params, count: count)
  }

  /// Performs a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - count: Count algorithm to use to count rows returned by the function.
  ///            Only applicable for set-returning functions.
  /// - Returns: A PostgrestTransformBuilder instance.
  /// - Throws: An error if the function call fails.
  public func rpc(
    fn: String,
    count: CountOption? = nil
  ) throws -> PostgrestTransformBuilder {
    try rpc(fn: fn, params: NoParams(), count: count)
  }

  func client<T>(_ client: APIClient, makeURLForRequest request: Request<T>) throws -> URL? {
    func makeURL() -> URL? {
      guard let url = request.url else {
        return nil
      }

      return url.scheme == nil ? client.configuration.baseURL?
        .appendingPathComponent(url.absoluteString) : url
    }

    guard let url = makeURL(), var components = URLComponents(
      url: url,
      resolvingAgainstBaseURL: false
    ) else {
      throw URLError(.badURL)
    }
    if let query = request.query, !query.isEmpty {
      let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + self
        .query(query)
      components.percentEncodedQuery = percentEncodedQuery
    }
    guard let url = components.url else {
      throw URLError(.badURL)
    }
    return url
  }

  private func escape(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: .postgrestURLQueryAllowed) ?? string
  }

  private func query(_ parameters: [(String, String?)]) -> String {
    parameters.compactMap { key, value in
      if let value {
        return (key, value)
      }
      return nil
    }
    .map { key, value in
      let escapedKey = escape(key)
      let escapedValue = escape(value)
      return "\(escapedKey)=\(escapedValue)"
    }
    .joined(separator: "&")
  }
}

private let supportedDateFormatters: [ISO8601DateFormatter] = [
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }(),
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }(),
]

extension JSONDecoder {
  /// The JSONDecoder instance for PostgREST responses.
  public static let postgrest = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)

      for formatter in supportedDateFormatters {
        if let date = formatter.date(from: string) {
          return date
        }
      }

      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid date format: \(string)"
      )
    }
    return decoder
  }()
}

extension JSONEncoder {
  /// The JSONEncoder instance for PostgREST requests.
  public static let postgrest = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()
}

extension CharacterSet {
  /// Creates a CharacterSet from RFC 3986 allowed characters.
  ///
  /// RFC 3986 states that the following characters are "reserved" characters.
  ///
  /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
  /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
  ///
  /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to
  /// allow
  /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?"
  /// and "/"
  /// should be percent-escaped in the query string.
  static let postgrestURLQueryAllowed: CharacterSet = {
    let generalDelimitersToEncode =
      ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    let encodableDelimiters =
      CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

    return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
  }()
}
