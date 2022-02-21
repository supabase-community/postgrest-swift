import Foundation

public struct PostgrestResponse: Hashable {
  public let data: Data
  public let status: Int
  public let count: Int?

  public init(data: Data, status: Int, count: Int?) {
    self.data = data
    self.status = status
    self.count = count
  }
}

extension PostgrestResponse {

  public func json() throws -> Any {
    try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
  }

  public func decoded<T: Decodable>(
    to type: T.Type = T.self, using decoder: JSONDecoder = JSONDecoder()
  ) throws -> T {
    try decoder.decode(type, from: data)
  }

  public func string(encoding: String.Encoding = .utf8) -> String? {
    String(data: data, encoding: encoding)
  }
}
