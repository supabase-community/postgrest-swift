import Foundation
import Get

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class PostgrestBuilder {
  var client: PostgrestClient
  var request: Request<Data>

  var url: String {
    get { request.url?.absoluteString ?? "" }
    set { request.url = URL(string: newValue) }
  }

  var queryParams: [(name: String, value: String?)] {
    get { request.query ?? [] }
    set { request.query = newValue }
  }

  var headers: [String: String] {
    get { request.headers ?? [:] }
    set { request.headers = newValue }
  }

  var schema: String?

  var method: String {
    get { request.method.rawValue }
    set { request.method = HTTPMethod(rawValue: newValue) }
  }

  var body: Encodable? {
    get { request.body }
    set { request.body = newValue }
  }

  init(
    client: PostgrestClient,
    request: Request<Data>,
    schema: String?
  ) {
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
    adaptRequest(head: head, count: count)
    let response = try await client.api.send(request.withResponse(T.self))
    return PostgrestResponse(underlyingResponse: response)
  }

  @discardableResult
  public func execute(
    head: Bool = false,
    count: CountOption? = nil
  ) async throws -> PostgrestResponse<Void> {
    adaptRequest(head: head, count: count)
    let response = try await client.api.send(request.withResponse(Void.self))
    return PostgrestResponse(underlyingResponse: response)
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
}
