import AnyCodable

public class PostgrestQueryBuilder: PostgrestBuilder {
  public func select(columns: String = "*") -> PostgrestFilterBuilder {
    method = "GET"
    var quoted = false
    let cleanedColumns = columns.compactMap { char -> String? in
      if char.isWhitespace, !quoted {
        return nil
      }
      if char == "\"" {
        quoted = !quoted
      }
      return String(char)
    }.reduce("", +)
    appendSearchParams(name: "select", value: cleanedColumns)
    return PostgrestFilterBuilder(
      url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
      body: body
    )
  }

  public func insert<U: Encodable>(
    values: U, upsert: Bool = false, onConflict: String? = nil,
    returning: PostgrestReturningOptions = .representation
  ) -> PostgrestBuilder {
    method = "POST"
    headers["Prefer"] =
      upsert
      ? "return=\(returning.rawValue),resolution=merge-duplicates" : "return=\(returning.rawValue)"
    if let onConflict = onConflict {
      appendSearchParams(name: "on_conflict", value: onConflict)
    }

    body = AnyEncodable(values)
    return self
  }

  public func upsert<U: Encodable>(
    values: U, onConflict: String? = nil, returning: PostgrestReturningOptions = .representation
  ) -> PostgrestBuilder {
    method = "POST"
    headers["Prefer"] = "return=\(returning.rawValue),resolution=merge-duplicates"
    if let onConflict = onConflict {
      appendSearchParams(name: "on_conflict", value: onConflict)
    }

    body = AnyEncodable(values)
    return self
  }

  public func update<U: Encodable>(
    values: U, returning: PostgrestReturningOptions = .representation
  )
    -> PostgrestFilterBuilder
  {
    method = "PATCH"
    headers["Prefer"] = "return=\(returning.rawValue)"
    body = AnyEncodable(values)
    return PostgrestFilterBuilder(
      url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
      body: body
    )
  }

  public func delete(returning: PostgrestReturningOptions = .representation)
    -> PostgrestFilterBuilder
  {
    method = "DELETE"
    headers["Prefer"] = "return=\(returning.rawValue)"
    return PostgrestFilterBuilder(
      url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
      body: body
    )
  }
}
