import Foundation

public protocol RequestAdapter {
  func adapt(_ request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void)
}
