import Foundation

#if compiler(>=5.5) && canImport(_Concurrency)
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
  extension PostgrestBuilder {
    @discardableResult
    public func execute(head: Bool = false, count: CountOption? = nil) async throws
      -> PostgrestResponse
    {
      try await withCheckedThrowingContinuation { continuation in
        self.execute(head: head, count: count) { result in
          continuation.resume(with: result)
        }
      }
    }
  }
#endif
