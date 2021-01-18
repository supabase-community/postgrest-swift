import Foundation

enum HTTPMethod: String {
	case Get = "GET"
	case Head = "HEAD"
	case Post = "POST"
	case Patch = "PATCH"
	case Delete = "DELETE"
}

public class PostgrestBuilder<T> {
	private var method: HTTPMethod
	private var url: URL
	private var headers: [String: String]
	private var schema: String?
	private var body: T?

	init(builder: PostgrestBuilder<T>) {
		self.method = builder.method
		self.url = builder.url
		self.headers = builder.headers
		self.schema = builder.schema
		self.body = builder.body
	}
}
