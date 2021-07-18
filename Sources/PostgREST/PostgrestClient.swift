public class PostgrestClient {
    var url: String
    var headers: [String: String]
    var schema: String?

    public init(url: String, headers: [String: String] = [:], schema: String?) {
        self.url = url
        self.headers = headers
        self.schema = schema
    }

    public func form(_ table: String) -> PostgrestQueryBuilder {
        return PostgrestQueryBuilder(url: "\(url)/\(table)", queryParams: [], headers: headers, schema: schema, method: nil, body: nil)
    }

    public func rpc(fn: String, parameters: [String: Any]?) -> PostgrestTransformBuilder {
        return PostgrestRpcBuilder(url: "\(url)/rpc/\(fn)", queryParams: [], headers: headers, schema: schema, method: nil, body: nil).rpc(parameters: parameters)
    }
}
