public class PostgrestRpcBuilder: PostgrestBuilder {
    public func rpc(parameters: [String: Any]?) -> PostgrestTransformBuilder {
        method = "POST"
        body = parameters
        return PostgrestTransformBuilder(
            url: url, queryParams: queryParams, headers: headers, schema: schema, method: schema,
            body: body
        )
    }
}
