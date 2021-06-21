
public class PostgrestRpcBuilder: PostgrestBuilder {
    public func rpc(parameters: [String: Any]?) -> PostgrestTransformBuilder {
        method = "POST"
        body = parameters
        return PostgrestTransformBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }
}
