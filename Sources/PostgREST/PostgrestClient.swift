import Foundation
import Get

/// PostgREST client.
public class PostgrestClient {
  let url: String
  let schema: String?
  let api: APIClient

  /// Creates a PostgREST client.
  /// - Parameters:
  ///   - url: URL of the PostgREST endpoint.
  ///   - headers: Custom headers.
  ///   - schema: Postgres schema to switch to.
  ///   - apiClientDelegate: Custom APIClientDelegate for the underlying APIClient.
  public init(
    url: String,
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
      if let customDelegate = apiClientDelegate {
        $0.delegate = MultiAPIClientDelegate([PostgrestAPIClientDelegate(), customDelegate])
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
      request: .init(path: "\(url)/\(table)"),
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
      request: .init(path: "\(url)/rpc/\(fn)", method: .post),
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
    guard 200 ..< 300 ~= response.statusCode else {
      return
    }

    throw try client.configuration.decoder.decode(PostgrestError.self, from: data)
  }
}

extension JSONDecoder {
  /// Default JSONDecoder instance used by PostgREST library.
  public static var postgrest = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()
}
