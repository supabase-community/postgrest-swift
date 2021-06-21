

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
        return PostgrestQueryBuilder(url: "\(url)/\(table)", headers: headers, schema: schema)
    }

    public func rpc(fn: String, parameters: [String: Any]?) -> PostgrestTransformBuilder {
        return PostgrestRpcBuilder(url: "\(url)/rpc/\(fn)", headers: headers, schema: schema).rpc(parameters: parameters)
    }
}
