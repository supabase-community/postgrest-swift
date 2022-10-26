import Foundation

public protocol PostgrestHTTPClient {
  func execute(_ request: URLRequest, client: PostgrestClient) async throws
    -> (Data, HTTPURLResponse)
}

public struct DefaultPostgrestHTTPClient: PostgrestHTTPClient {
  public init() {}

  public func execute(
    _ request: URLRequest,
    client _: PostgrestClient
  ) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    return (data, httpResponse)
  }
}
