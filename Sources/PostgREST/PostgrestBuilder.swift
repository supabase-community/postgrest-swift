import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class PostgrestBuilder {
  let configuration: PostgrestClient.Configuration
  let url: URL
  var queryParams: [(name: String, value: String?)]
  var headers: [String: String]
  var method: String
  var body: Data?

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

  @discardableResult
  public func execute(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<Void> {
    fetchOptions = FetchOptions(head: head, count: count)
    return try await execute { _ in () }
  }

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

    guard 200 ..< 300 ~= httpResponse.statusCode else {
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
