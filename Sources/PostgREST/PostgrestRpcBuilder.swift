import AnyCodable

public class PostgrestRpcBuilder: PostgrestBuilder {
  public func rpc<U: Encodable>(parameters: U?) -> PostgrestTransformBuilder {
    method = "POST"
    body = AnyEncodable(parameters)
    return PostgrestTransformBuilder(
      url: url,
      queryParams: queryParams,
      headers: headers,
      schema: schema,
      method: method,
      body: body)
  }

  public func rpc() -> PostgrestTransformBuilder {
    method = "POST"
    return PostgrestTransformBuilder(
      url: url,
      queryParams: queryParams,
      headers: headers,
      schema: schema,
      method: method,
      body: body)
  }
}
