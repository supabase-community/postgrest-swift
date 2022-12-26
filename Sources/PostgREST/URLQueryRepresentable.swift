import Foundation

/// A type that can fit into the query part of a URL.
public protocol URLQueryRepresentable {
  /// A String representation of this instance that can fit as a query parameter's value.
  var queryValue: String { get }
}

extension String: URLQueryRepresentable {
  public var queryValue: String { self }
}

extension Int: URLQueryRepresentable {
  public var queryValue: String { "\(self)" }
}

extension Double: URLQueryRepresentable {
  public var queryValue: String { "\(self)" }
}

extension Bool: URLQueryRepresentable {
  public var queryValue: String { "\(self)" }
}

extension UUID: URLQueryRepresentable {
  public var queryValue: String { uuidString }
}

extension Array: URLQueryRepresentable where Element: URLQueryRepresentable {
  public var queryValue: String {
      self.map(\.queryValue).joined(separator: ",")
  }
}

extension Dictionary: URLQueryRepresentable where Element: URLQueryRepresentable {
  public var queryValue: String {
      self.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
  }
}