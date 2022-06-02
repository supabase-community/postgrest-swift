import AnyCodable

public class PostgrestRpcBuilder: PostgrestBuilder {
  public func rpc<U: Encodable>(parameters: U?) -> PostgrestTransformBuilder {
    method = "POST"
    body = AnyEncodable(parameters)
    return PostgrestTransformBuilder(self)
  }

  public func rpc() -> PostgrestTransformBuilder {
    method = "POST"
    return PostgrestTransformBuilder(self)
  }
}
