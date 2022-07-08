import AnyCodable
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class PostgrestBuilder {
  unowned var client: PostgrestClient

  var url: String
  var queryParams: [(name: String, value: String)]
  var headers: [String: String]
  var schema: String?
  var method: String?
  var body: AnyEncodable?
  var delegate: PostgrestClientDelegate

  init(
    client: PostgrestClient,
    url: String,
    queryParams: [(name: String, value: String)] = [],
    headers: [String: String],
    schema: String?,
    method: String?,
    body: AnyEncodable?,
    delegate: PostgrestClientDelegate
  ) {
    self.client = client
    self.url = url
    self.queryParams = queryParams
    self.headers = headers
    self.schema = schema
    self.method = method
    self.body = body
    self.delegate = delegate
  }

  convenience init(_ other: PostgrestBuilder) {
    self.init(
      client: other.client,
      url: other.url,
      queryParams: other.queryParams,
      headers: other.headers,
      schema: other.schema,
      method: other.method,
      body: other.body,
      delegate: other.delegate
    )
  }

  /// Executes the built query or command.
  /// - Parameters:
  ///   - head: If `true` use `HEAD` for the HTTP method when building the URLRequest. Defaults to `false`
  ///   - count: A `CountOption` determining how many items to return. Defaults to `nil`
  ///   - completion: Escaping completion handler with either a `PostgrestResponse` or an `Error`. Called after API call is completed and validated.
  public func execute(
    head: Bool = false,
    count: CountOption? = nil,
    completion: @escaping (Result<PostgrestResponse, Error>) -> Void
  ) {
    do {
      let request = try buildURLRequest(head: head, count: count)
      delegate.client(client, willSendRequest: request) { request in
        URLSession.shared.fetch(request) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case let .success((data, response)):
            do {
              try Self.validate(data: data, response: response)
              let response = PostgrestResponse(data: data, response: response)
              completion(.success(response))
            } catch {
              completion(.failure(error))
            }
          }
        }
      }
    } catch {
      completion(.failure(error))
    }
  }

  /// Validates the response from PostgREST
  /// - Parameters:
  ///   - data: `Data` received from the server.
  ///   - response: `HTTPURLResponse` received from the server.
  /// - Throws: Throws `PostgrestError` if invalid JSON object.
  private static func validate(data: Data, response: HTTPURLResponse) throws {
    if 200..<300 ~= response.statusCode {
      return
    }

    throw try JSONDecoder.postgrest.decode(PostgrestError.self, from: data)
  }

  /// Builds the URL request for PostgREST
  /// - Parameters:
  ///   - head: If on, use `HEAD` as the HTTP method.
  ///   - count: A `CountOption`,
  /// - Throws: Throws a `PostgressError`
  /// - Returns: Returns a valid URLRequest for the current query.
  func buildURLRequest(head: Bool, count: CountOption?) throws -> URLRequest {
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

    guard let method = method else {
      throw PostgrestError(message: "Missing table operation: select, insert, update or delete")
    }

    headers["Content-Type"] = "application/json"

    if let schema = schema {
      if method == "GET" || method == "HEAD" {
        headers["Accept-Profile"] = schema
      } else {
        headers["Content-Profile"] = schema
      }
    }

    guard var components = URLComponents(string: url) else {
      throw URLError(.badURL)
    }

    if !queryParams.isEmpty {
      components.queryItems = components.queryItems ?? []
      components.queryItems!.append(contentsOf: queryParams.map(URLQueryItem.init))
    }

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.allHTTPHeaderFields = headers
    if let body = body {
      request.httpBody = try JSONEncoder.postgrest.encode(body)
    }
    return request
  }

  func appendSearchParams(name: String, value: String) {
    queryParams.append((name, value))
  }
}

extension JSONEncoder {
  /// Default JSONEncoder instance used by PostgREST library.
  public static var postgrest = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    if #available(macOS 10.12, *) {
      encoder.dateEncodingStrategy = .iso8601
    } else {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      encoder.dateEncodingStrategy = .formatted(formatter)
    }
    return encoder
  }()
}

extension URLSession {
  func fetch(
    _ request: URLRequest,
    completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void
  ) {
    let dataTask = dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(URLError(.badServerResponse)))
        return
      }

      guard let data = data else {
        completion(.failure(URLError(.badServerResponse)))
        return
      }

      completion(.success((data, httpResponse)))
    }

    dataTask.resume()
  }
}
