import Foundation

/// Error format
/// For more information see [postgrest.org](https://postgrest.org/en/stable/api.html?highlight=options#errors-and-http-status-codes)
public struct PostgrestError {
	var message: String
	var details: String
	var hint: String
	var code: String
}

/// Response format
/// For more information see [Linked Issue](https://github.com/supabase/supabase-js/issues/32)
public protocol PostgrestResponseBase {
	var status: Int! { get set }
	var statusText: String! { get set }
}

public class PostgrestResponse<T>: PostgrestResponseBase {
	public var status: Int!
	public var statusText: String!
	public var error: String?
	public var count: Int? = nil
}

public class PostgrestResponseSuccess<T>: PostgrestResponse<T> {
	public var data: [T] = []
	public var body: [T] = []
}
public class PostgrestResponseFailure<T>: PostgrestResponse<T> {
	public var data: [T]? = nil
	/// For backward compatibility: body === data
	public var body: [T]? = nil
}

public class PostgrestSingleResponse<T>: PostgrestResponseBase {
	public var status: Int!
	public var statusText: String!
}

public class PostgrestSingleResponseSuccess<T>: PostgrestSingleResponse<T> {
	public var data: T!
	public var body: T!
}

public class PostgrestSingleResponseFailure<T>: PostgrestSingleResponse<T> {
	public var data: T? = nil
	/// For backward compatibility: body === data
	public var body: T? = nil
}
