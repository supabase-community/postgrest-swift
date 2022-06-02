let version = "0.0.3"
let defaultHeaders = [
  "X-Client-Info": "postgrest-swiift/\(version)"
]

/// This is the main class in this package. Use it to execute queries on a PostgREST instance on Supabase.
public class PostgrestClient {
  /// Configuration for the client
  public var config: PostgrestClientConfig

  /// Struct for PostgrestClient config options
  public struct PostgrestClientConfig {
    public var url: String
    public var headers: [String: String]
    public var fetch: Fetch?
    public var schema: String?

    public init(url: String, headers: [String: String] = [:], fetch: Fetch?, schema: String?) {
      self.url = url
      self.headers = headers.merging(defaultHeaders) { old, _ in old }
      self.fetch = fetch
      self.schema = schema
    }
  }

  /// Initializes the `PostgrestClient` with the correct parameters.
  /// - Parameters:
  ///   - url: Url of your supabase db instance
  ///   - headers: Headers to include when querying the database. Eg, an authentication header
  ///   - schema: Schema ID to use
  public init(url: String, headers: [String: String] = [:], fetch: Fetch?, schema: String?) {
    self.config = PostgrestClientConfig(
      url: url,
      headers: headers,
      fetch: fetch,
      schema: schema
    )
  }

  /// Initializes the `PostgrestClient` with a config object
  /// - Parameter config: A `PostgrestClientConfig` struct with the correct parameters
  public init(config: PostgrestClientConfig) {
    self.config = config
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
    return PostgrestQueryBuilder(
      url: "\(config.url)/\(table)", headers: config.headers,
      schema: config.schema, method: nil, body: nil, fetch: config.fetch)
  }

  /// Call a stored procedure, aka a "Remote Procedure Call"
  /// - Parameters:
  ///   - fn: Procedure name to call.
  ///   - parameters: Parameters to pass to the procedure.
  /// - Returns: `PostgrestTransformBuilder`
  public func rpc<U: Encodable>(fn: String, parameters: U?) -> PostgrestTransformBuilder {
    return PostgrestRpcBuilder(
      url: "\(config.url)/rpc/\(fn)", headers: config.headers,
      schema: config.schema, method: nil, body: nil, fetch: config.fetch
    ).rpc(parameters: parameters)
  }

  /// Call a stored procedure, aka a "Remote Procedure Call"
  /// - Parameters:
  ///   - fn: Procedure name to call.
  /// - Returns: `PostgrestTransformBuilder`
  public func rpc(fn: String) -> PostgrestTransformBuilder {
    return PostgrestRpcBuilder(
      url: "\(config.url)/rpc/\(fn)", headers: config.headers,
      schema: config.schema, method: nil, body: nil, fetch: config.fetch
    ).rpc()
  }
}
