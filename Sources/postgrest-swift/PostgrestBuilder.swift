import Foundation

enum HTTPMethod: String {
	case Get = "GET"
	case Head = "HEAD"
	case Post = "POST"
	case Patch = "PATCH"
	case Delete = "DELETE"
}

public class PostgrestBuilder<T> {
	var method: HTTPMethod
	var url: URL
	var headers: [String: String]
	var schema: String?
	var body: T?

	init(builder: PostgrestBuilder<T>) {
		self.method = builder.method
		self.url = builder.url
		self.headers = builder.headers
		self.schema = builder.schema
		self.body = builder.body
	}
}
