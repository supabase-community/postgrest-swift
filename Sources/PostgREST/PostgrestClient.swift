/// # PostgrestClient
///
/// This is the main class in this package. Use it to execute queries on a PostgREST instance on Supabase.
public class PostgrestClient {
  /// Configuration for the client
  public var config: PostgrestClientConfig

  /// Struct for PostgrestClient config options
  public struct PostgrestClientConfig {
    public var url: String
    public var headers: [String: String]
    public var schema: String?
  }

  /// Initializes the `PostgrestClient` with the correct parameters.
  /// - Parameters:
  ///   - url: Url of your supabase db instance
  ///   - headers: Headers to include when querying the database. Eg, an authentication header
  ///   - schema: Schema ID to use
  public init(url: String, headers: [String: String] = [:], schema: String?) {
    self.config = PostgrestClientConfig(
      url: url,
      headers: headers,
      schema: schema)
  }

  /// Initializes the `PostgrestClient` with a config object
  /// - Parameter config: A `PostgrestClientConfig` struct with the correct parameters
  public init(config: PostgrestClientConfig) {
    self.config = config
  }

  /// Select a table to query from
  /// - Parameter table: The ID of the table to query
  /// - Returns: `PostgrestQueryBuilder`
  public func from(_ table: String) -> PostgrestQueryBuilder {
    return PostgrestQueryBuilder(
      url: "\(config.url)/\(table)", queryParams: [], headers: config.headers,
      schema: config.schema, method: nil, body: nil)
  }

  /// Call a stored procedure, aka a "Remote Procedure Call"
  /// - Parameters:
  ///   - fn: Procedure name to call.
  ///   - parameters: Parameters to pass to the procedure.
  /// - Returns: `PostgrestTransformBuilder`
  public func rpc<U: Encodable>(fn: String, parameters: U?) -> PostgrestTransformBuilder {
    return PostgrestRpcBuilder(
      url: "\(config.url)/rpc/\(fn)", queryParams: [], headers: config.headers,
      schema: config.schema, method: nil, body: nil
    ).rpc(parameters: parameters)
  }

  /// Call a stored procedure, aka a "Remote Procedure Call"
  /// - Parameters:
  ///   - fn: Procedure name to call.
  /// - Returns: `PostgrestTransformBuilder`
  public func rpc(fn: String) -> PostgrestTransformBuilder {
    return PostgrestRpcBuilder(
      url: "\(config.url)/rpc/\(fn)", queryParams: [], headers: config.headers,
      schema: config.schema, method: nil, body: nil
    ).rpc()
  }
}
