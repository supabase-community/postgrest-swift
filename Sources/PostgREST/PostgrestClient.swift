/**
 # PostgrestClient
 
 This is the main class in this package. Use it to execute queries on a PostgREST instance on Supabase.
 */
public class PostgrestClient {
    var url: String
    var headers: [String: String]
    var schema: String?
    
    /// Initializes the `PostgrestClient` with the correct parameters.
    /// - Parameters:
    ///   - url: Url of your supabase db instance
    ///   - headers: Headers to include when querying the database. Eg, an authentication header
    ///   - schema: Schema ID to use
    public init(url: String, headers: [String: String] = [:], schema: String?) {
        self.url = url
        self.headers = headers
        self.schema = schema
    }
    
    /// Select a table to query from
    /// - Parameter table: The ID of the table to query
    /// - Returns: `PostgrestQueryBuilder`
    public func from(_ table: String) -> PostgrestQueryBuilder {
        return PostgrestQueryBuilder(url: "\(url)/\(table)", queryParams: [], headers: headers, schema: schema, method: nil, body: nil)
    }
    
    /// Call a stored procedure, aka a "Remote Procedure Call"
    /// - Parameters:
    ///   - fn: Procedure name to call.
    ///   - parameters: Parameters to pass to the procedure.
    /// - Returns: `PostgrestTransformBuilder`
    public func rpc(fn: String, parameters: [String: Any]?) -> PostgrestTransformBuilder {
        return PostgrestRpcBuilder(url: "\(url)/rpc/\(fn)", queryParams: [], headers: headers, schema: schema, method: nil, body: nil).rpc(parameters: parameters)
    }
}
