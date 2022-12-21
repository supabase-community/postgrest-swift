import Foundation
import Get

public struct PostgrestResponse<T> {
  public let underlyingResponse: Response<T>

  public var status: Int {
    underlyingResponse.statusCode ?? 0
  }

  public var value: T {
    underlyingResponse.value
  }

  public let count: Int?

  public init(underlyingResponse response: Response<T>) {
    var count: Int?

    if let contentRange = (response.response as! HTTPURLResponse)
      .allHeaderFields["content-range"] as? String,
      let lastElement = contentRange.split(separator: "/").last
    {
      count = lastElement == "*" ? nil : Int(lastElement)
    }

    underlyingResponse = response
    self.count = count
  }
}
