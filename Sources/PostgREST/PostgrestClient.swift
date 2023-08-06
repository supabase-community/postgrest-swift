import Foundation
import Get
import GetExtensions

/// PostgREST client.
public class PostgrestClient {
  let url: URL
  let schema: String?
  let api: APIClient

  /// Creates a PostgREST client.
  /// - Parameters:
  ///   - url: URL of the PostgREST endpoint.
  ///   - headers: Custom headers.
  ///   - schema: Postgres schema to switch to.
  ///   - apiClientDelegate: Custom APIClientDelegate for the underlying APIClient.
  public init(
    url: URL,
    headers: [String: String] = [:],
    schema: String?,
    apiClientDelegate: APIClientDelegate? = nil
  ) {
    self.url = url
    self.schema = schema
    api = APIClient(baseURL: nil) {
      var headers = headers
      headers["X-Client-Info"] = "postgrest-swift/\(version)"
      $0.sessionConfiguration.httpAdditionalHeaders = headers
      $0.decoder = .postgrest
      $0.encoder = .postgrest
      if let customDelegate = apiClientDelegate {
        $0.delegate = MultiAPIClientDelegate([customDelegate, PostgrestAPIClientDelegate()])
      } else {
        $0.delegate = PostgrestAPIClientDelegate()
      }
    }
  }

  /// Perform a query on a table or a view.
  /// - Parameter table: The table or view name to query.
  public func from(_ table: String) -> PostgrestQueryBuilder {
    PostgrestQueryBuilder(
      client: self,
      request: Request(url: url.appendingPathComponent(table)),
      schema: schema
    )
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count:  Count algorithm to use to count rows returned by the function. Only applicable for
  /// [set-returning functions](https://www.postgresql.org/docs/current/functions-srf.html).
  public func rpc<U: Encodable>(
    fn: String,
    params: U,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    PostgrestRpcBuilder(
      client: self,
      request: Request(
        url: url.appendingPathComponent("rpc").appendingPathComponent(fn),
        method: .post
      ),
      schema: schema
    ).rpc(params: params, count: count)
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count:  Count algorithm to use to count rows returned by the function. Only applicable for
  /// [set-returning functions](https://www.postgresql.org/docs/current/functions-srf.html).
  public func rpc(
    fn: String,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    rpc(fn: fn, params: NoParams(), count: count)
  }
}

struct PostgrestAPIClientDelegate: APIClientDelegate {
  func client(
    _ client: APIClient,
    validateResponse response: HTTPURLResponse,
    data: Data,
    task _: URLSessionTask
  ) throws {
    if 200 ..< 300 ~= response.statusCode {
      return
    }

    throw try client.configuration.decoder.decode(PostgrestError.self, from: data)
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
  static let postgrest = { () -> JSONDecoder in
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
  static let postgrest = { () -> JSONEncoder in
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
