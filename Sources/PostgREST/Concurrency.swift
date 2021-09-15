import Foundation

#if compiler(>=5.5)
@available(iOS 15.0.0, macOS 12.0.0, *)
extension PostgrestBuilder {
  public func execute(head: Bool = false, count: CountOption? = nil) async throws -> PostgrestResponse {
    try await withCheckedThrowingContinuation { continuation in
      self.execute(head: head, count: count) { result in
        continuation.resume(with: result)
      }
    }
  }
}
#endif
