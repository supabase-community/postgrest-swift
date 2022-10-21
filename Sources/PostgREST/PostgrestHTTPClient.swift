import Foundation

public protocol PostgrestHTTPClient {
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct DefaultPostgrestHTTPClient: PostgrestHTTPClient {
  public init() {}
  
  public func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard
          let data = data,
          let httpResponse = response as? HTTPURLResponse
        else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }

        continuation.resume(returning: (data, httpResponse))
      }

      dataTask.resume()
    }
  }
}
