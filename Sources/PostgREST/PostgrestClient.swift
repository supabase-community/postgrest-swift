import Foundation
import Get

/// This is the main class in this package. Use it to execute queries on a PostgREST instance on
/// Supabase.
public class PostgrestClient {
  /// Configuration for the client
  public var config: PostgrestClientConfig

  let api: APIClient

  /// Struct for PostgrestClient config options
  public struct PostgrestClientConfig {
    public var url: String
    public var headers: [String: String]
    public var schema: String?
    public var http: PostgrestHTTPClient

    public init(
      url: String,
      headers: [String: String] = [:],
      schema: String?,
      http: PostgrestHTTPClient? = nil
    ) {
      self.url = url
      self.headers = headers.merging(Constants.defaultHeaders) { old, _ in old }
      self.schema = schema
      self.http = http ?? DefaultPostgrestHTTPClient()
    }
  }

  /// Initializes the `PostgrestClient` with the correct parameters.
  /// - Parameters:
  ///   - url: Url of your supabase db instance
  ///   - headers: Headers to include when querying the database. Eg, an authentication header
  ///   - schema: Schema ID to use
  public convenience init(
    url: String,
    headers: [String: String] = [:],
    schema: String?,
    http: PostgrestHTTPClient? = nil
  ) {
    self.init(config: .init(url: url, headers: headers, schema: schema, http: http))
  }

  /// Initializes the `PostgrestClient` with a config object
  /// - Parameter config: A `PostgrestClientConfig` struct with the correct parameters
  public init(config: PostgrestClientConfig) {
    self.config = config
    self.api = APIClient(baseURL: nil)
  }

  /// Authenticates the request with JWT.
  /// - Parameter token: The JWT token to use.
  public func auth(_ token: String) -> PostgrestClient {
    config.headers["Authorization"] = "Bearer \(token)"
    return self
  }

  /// Select a table to query from
  /// - Parameter table: The ID of the table to query
  /// - Returns: `PostgrestQueryBuilder`
  public func from(_ table: String) -> PostgrestQueryBuilder {
    PostgrestQueryBuilder(
      client: self,
      request: .init(path: "\(config.url)/\(table)", headers: config.headers),
      schema: config.schema
    )
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  public func rpc<U: Encodable>(
    fn: String,
    params: U,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    PostgrestRpcBuilder(
      client: self,
      request: .init(path: "\(config.url)/rpc/\(fn)", method: .post, headers: config.headers),
      schema: config.schema
    ).rpc(params: params, count: count)
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  public func rpc(
    fn: String,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    rpc(fn: fn, params: NoParams(), count: count)
  }
}

struct PostgrestAPIClientDelegate: APIClientDelegate {
  func client(_ client: APIClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws {
    guard 200 ..< 300 ~= response.statusCode else {
      return
    }

    throw try JSONDecoder.postgrest.decode(PostgrestError.self, from: data)
  }
}
