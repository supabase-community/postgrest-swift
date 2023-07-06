import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// The builder class for creating and executing requests to a PostgREST server.
public class PostgrestBuilder {
  /// The configuration for the PostgREST client.
  let configuration: PostgrestClient.Configuration
  /// The URL for the request.
  let url: URL
  /// The query parameters for the request.
  var queryParams: [(name: String, value: String?)]
  /// The headers for the request.
  var headers: [String: String]
  /// The HTTP method for the request.
  var method: String
  /// The body data for the request.
  var body: Data?

  /// The options for fetching data from the PostgREST server.
  var fetchOptions = FetchOptions()

  init(
    configuration: PostgrestClient.Configuration,
    url: URL,
    queryParams: [(name: String, value: String?)],
    headers: [String: String],
    method: String,
    body: Data?
  ) {
    self.configuration = configuration
    self.url = url
    self.queryParams = queryParams
    self.headers = headers
    self.method = method
    self.body = body
  }

  convenience init(_ other: PostgrestBuilder) {
    self.init(
      configuration: other.configuration,
      url: other.url,
      queryParams: other.queryParams,
      headers: other.headers,
      method: other.method,
      body: other.body
    )
  }

  /// Executes the request and returns a response of type Void.
  /// - Parameters:
  ///   - head: Determines whether to only retrieve the response headers.
  ///   - count: The count option for the request.
  /// - Returns: A `PostgrestResponse<Void>` instance representing the response.
  @discardableResult
  public func execute(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<Void> {
    fetchOptions = FetchOptions(head: head, count: count)
    return try await execute { _ in () }
  }

  /// Executes the request and returns a response of the specified type.
  /// - Parameters:
  ///   - head: Determines whether to only retrieve the response headers.
  ///   - count: The count option for the request.
  /// - Returns: A `PostgrestResponse<T>` instance representing the response.
  @discardableResult
  public func execute<T: Decodable>(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<T> {
    fetchOptions = FetchOptions(head: head, count: count)
    return try await execute { [configuration] data in
      try configuration.decoder.decode(T.self, from: data)
    }
  }

  func appendSearchParams(name: String, value: String) {
    queryParams.append((name, value))
  }

  private func execute<T>(decode: (Data) throws -> T) async throws -> PostgrestResponse<T> {
    if fetchOptions.head {
      method = "HEAD"
    }

    if let count = fetchOptions.count {
      if let prefer = headers["Prefer"] {
        headers["Prefer"] = "\(prefer),count=\(count.rawValue)"
      } else {
        headers["Prefer"] = "count=\(count.rawValue)"
      }
    }

    headers["Content-Type"] = "application/json"

    if let schema = configuration.schema {
      if method == "GET" || method == "HEAD" {
        headers["Accept-Profile"] = schema
      } else {
        headers["Content-Profile"] = schema
      }
    }

    let urlRequest = try makeURLRequest()

    let (data, response) = try await configuration.session.data(for: urlRequest)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard 200..<300 ~= httpResponse.statusCode else {
      let error = try configuration.decoder.decode(PostgrestError.self, from: data)
      throw error
    }

    let value = try decode(data)
    return PostgrestResponse(data: data, response: httpResponse, value: value)
  }

  private func makeURLRequest() throws -> URLRequest {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw URLError(.badURL)
    }

    if !queryParams.isEmpty {
      components.queryItems = queryParams.map(URLQueryItem.init)
    }

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    var urlRequest = URLRequest(url: url)

    for (key, value) in headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }

    urlRequest.httpMethod = method

    if let body {
      urlRequest.httpBody = try configuration.encoder.encode(body)
    }

    return urlRequest
  }
}
