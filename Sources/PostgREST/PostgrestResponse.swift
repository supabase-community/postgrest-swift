import Foundation

public struct PostgrestResponse<T> {
  public let underlyingResponse: HTTPURLResponse

  public var status: Int {
    underlyingResponse.statusCode
  }

  public let result: Result<T, Error>

  @available(
    *,
    deprecated,
    message: "`value` is deprecated, please use `try result.get()` instead."
  )
  public var value: T {
    get throws { try result.get() }
  }

  public var error: Error? {
    if case let .failure(error) = result {
      return error
    }

    return nil
  }

  public let count: Int?

  public init(
    result: Result<T, Error>,
    underlyingResponse response: HTTPURLResponse
  ) {
    var count: Int?

    if let contentRange = response.allHeaderFields["content-range"] as? String,
       let lastElement = contentRange.split(separator: "/").last
    {
      count = lastElement == "*" ? nil : Int(lastElement)
    }

    underlyingResponse = response
    self.result = result
    self.count = count
  }
}
