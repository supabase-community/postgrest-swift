import Foundation

public class PostgrestClient {
	var url: String
	var headers: [String: String]
	var schema: String?
	
	/// Creates a PostgREST client.
	/// - Parameters:
	///   - url: URL of the PostgREST endpoint.
	///   - headers: Custom headers.
	///   - schema: Postgres schema to switch to.
	public init(url: String,
				headers: [String: String] = [String: String](),
				schema: String? = nil) {
		self.url = url
		self.headers = headers
		self.schema = schema
	}
	
	/// Authenticates the request with JWT.
	/// - Parameter token: The JWT token to use.
	/// - Returns: Instance of the current PostgrestClient.
	public func auth(token: String) -> PostgrestClient {
		self.headers["Authorization"] = "Bearer \(token)"
		return self
	}
}
