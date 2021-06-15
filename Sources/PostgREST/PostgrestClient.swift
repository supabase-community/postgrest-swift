

class PostgrestClient {
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
}
