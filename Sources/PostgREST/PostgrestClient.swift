import Foundation

/// PostgREST client.
public class PostgrestClient {
  public typealias Fetch = (URLRequest) async throws -> (Data, URLResponse)

  let url: URL
  let schema: String?
  var fetch: Fetch

  /// Creates a PostgREST client.
  /// - Parameters:
  ///   - url: URL of the PostgREST endpoint.
  ///   - headers: Custom headers.
  ///   - schema: Postgres schema to switch to.
  ///   - fetch: Custom ``Fetch`` implementation for the underlying api calls.
  public init(
    url: URL,
    headers _: [String: String] = [:],
    schema: String?,
    fetch: Fetch? = nil
  ) {
    self.url = url
    self.schema = schema
    self.fetch = fetch ?? URLSession.shared.data(for:)
  }

  /// Perform a query on a table or a view.
  /// - Parameter table: The table or view name to query.
  public func from(_ table: String) -> PostgrestQueryBuilder {
    PostgrestQueryBuilder(
      client: self,
      request: .init(url: url.appendingPathComponent(table).absoluteString),
      schema: schema
    )
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count:  Count algorithm to use to count rows returned by the function. Only applicable for
  /// [set-returning functions](https://www.postgresql.org/docs/current/functions-srf.html).
  public func rpc<U: Encodable>(
    fn: String,
    params: U,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    PostgrestRpcBuilder(
      client: self,
      request: .init(
        url: url.appendingPathComponent("rpc").appendingPathComponent(fn).absoluteString,
        method: "POST"
      ),
      schema: schema
    ).rpc(params: params, count: count)
  }

  /// Perform a function call.
  /// - Parameters:
  ///   - fn: The function name to call.
  ///   - params: The parameters to pass to the function call.
  ///   - count:  Count algorithm to use to count rows returned by the function. Only applicable for
  /// [set-returning functions](https://www.postgresql.org/docs/current/functions-srf.html).
  public func rpc(
    fn: String,
    count: CountOption? = nil
  ) -> PostgrestTransformBuilder {
    rpc(fn: fn, params: NoParams(), count: count)
  }
}

private let supportedDateFormatters: [ISO8601DateFormatter] = [
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }(),
  { () -> ISO8601DateFormatter in
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }(),
]

extension JSONDecoder {
  static let postgrest = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)

      for formatter in supportedDateFormatters {
        if let date = formatter.date(from: string) {
          return date
        }
      }

      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid date format: \(string)"
      )
    }
    return decoder
  }()
}

extension JSONEncoder {
  static let postgrest = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()
}
