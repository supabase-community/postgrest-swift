import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class PostgrestBuilder {
  let client: PostgrestClient
  let url: URL
  var queryParams: [(name: String, value: String?)]
  var headers: [String: String]
  let schema: String?
  var method: String
  var body: Data?

  var fetchOptions = FetchOptions()

  init(
    client: PostgrestClient,
    url: URL,
    queryParams: [(name: String, value: String?)],
    headers: [String: String],
    schema: String?,
    method: String,
    body: Data?
  ) {
    self.client = client
    self.url = url
    self.queryParams = queryParams
    self.headers = headers
    self.schema = schema
    self.method = method
    self.body = body
  }

  convenience init(_ other: PostgrestBuilder) {
    self.init(
      client: other.client,
      url: other.url,
      queryParams: other.queryParams,
      headers: other.headers,
      schema: other.schema,
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
    return try await execute { [decoder = client.decoder] data in
      try decoder.decode(T.self, from: data)
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

    if let schema = schema {
      if method == "GET" || method == "HEAD" {
        headers["Accept-Profile"] = schema
      } else {
        headers["Content-Profile"] = schema
      }
    }

    let urlRequest = try makeURLRequest()

    let (data, response) = try await client.session.data(for: urlRequest)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      let error = try client.decoder.decode(PostgrestError.self, from: data)
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
      urlRequest.httpBody = try client.encoder.encode(body)
    }

    return urlRequest
  }
}
