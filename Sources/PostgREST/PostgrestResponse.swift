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
    to type: T.Type = T.self, using decoder: JSONDecoder = .postgrest
  ) throws -> T {
    try decoder.decode(type, from: data)
  }

  public func string(encoding: String.Encoding = .utf8) -> String? {
    String(data: data, encoding: encoding)
  }
}

extension JSONDecoder {
  /// Default JSONDecoder instance used by PostgREST library.
  public static var postgrest = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    if #available(macOS 10.12, *) {
      decoder.dateDecodingStrategy = .iso8601
    } else {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      decoder.dateDecodingStrategy = .formatted(formatter)
    }
    return decoder
  }()
}
