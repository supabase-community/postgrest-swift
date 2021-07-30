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

    public func insert(values: Any, upsert: Bool = false, onConflict: String? = nil, returning: PostgrestReturningOptions = .representation) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = upsert ? "return=\(returning.rawValue),resolution=merge-duplicates" : "return=\(returning.rawValue)"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    public func upsert(values: Any, onConflict: String? = nil, returning: PostgrestReturningOptions = .representation) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = "return=\(returning.rawValue),resolution=merge-duplicates"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    public func update(values: Any, returning: PostgrestReturningOptions = .representation) -> PostgrestFilterBuilder {
        method = "PATCH"
        headers["Prefer"] = "return=\(returning.rawValue)"
        body = values
        return PostgrestFilterBuilder(
            url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
            body: body
        )
    }

    public func delete(returning: PostgrestReturningOptions = .representation) -> PostgrestFilterBuilder {
        method = "DELETE"
        headers["Prefer"] = "return=\(returning.rawValue)"
        return PostgrestFilterBuilder(
            url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
            body: body
        )
    }
}
