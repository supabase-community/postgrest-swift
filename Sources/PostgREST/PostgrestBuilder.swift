import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class PostgrestBuilder {
  struct Request {
    var url: String
    var query: [(name: String, value: String?)] = []
    var headers: [String: String] = [:]
    var method: String = "GET"
    var body: Encodable?
  }

  var client: PostgrestClient
  var request: Request

  var url: String {
    get { request.url }
    set { request.url = newValue }
  }

  var queryParams: [(name: String, value: String?)] {
    get { request.query }
    set { request.query = newValue }
  }

  var headers: [String: String] {
    get { request.headers }
    set { request.headers = newValue }
  }

  var schema: String?

  var method: String {
    get { request.method }
    set { request.method = newValue }
  }

  var body: Encodable? {
    get { request.body }
    set { request.body = newValue }
  }

  init(client: PostgrestClient, request: Request, schema: String?) {
    self.client = client
    self.request = request
    self.schema = schema
  }

  convenience init(_ other: PostgrestBuilder) {
    self.init(
      client: other.client,
      request: other.request,
      schema: other.schema
    )
  }

  @discardableResult
  public func execute<T: Decodable>(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<T> {
    let request = try makeRequest(head: head, count: count)
    return try await performRequest(request) { data in
      try JSONDecoder.postgrest.decode(T.self, from: data)
    }
  }

  @discardableResult
  public func execute(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<Void> {
    let request = try makeRequest(head: head, count: count)
    return try await performRequest(request) { _ in () }
  }

  func adaptRequest(head: Bool, count: CountOption?) {
    if head {
      method = "HEAD"
    }

    if let count = count {
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
  }

  func appendSearchParams(name: String, value: String) {
    queryParams.append((name, value))
  }

  private func performRequest<T>(
    _ request: URLRequest,
    decode: (Data) throws -> T
  ) async throws -> PostgrestResponse<T> {
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw URLError(.badServerResponse)
    }

    let result = Result {
      try decode(data)
    }

    return PostgrestResponse(result: result, underlyingResponse: httpResponse)
  }

  private func makeRequest(head: Bool, count: CountOption?) throws -> URLRequest {
    adaptRequest(head: head, count: count)

    guard var urlComponents = URLComponents(string: url) else {
      throw URLError(.badURL)
    }

    if !queryParams.isEmpty {
      let queryItems = queryParams.map { URLQueryItem(name: $0.name, value: $0.value) }
      urlComponents.queryItems = urlComponents.queryItems ?? []
      urlComponents.queryItems!.append(contentsOf: queryItems)
    }

    guard let url = urlComponents.url else { throw URLError(.badURL) }
    var request = URLRequest(url: url)
    request.httpMethod = method

    if let body {
      request.httpBody = try JSONEncoder.postgrest.encode(body)
    }

    headers.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }

    return request
  }
}
