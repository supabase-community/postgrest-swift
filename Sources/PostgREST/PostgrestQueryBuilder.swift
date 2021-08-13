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

    public func insert(values: Any, upsert: Bool = false, onConflict: String? = nil) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = upsert ? "return=representation,resolution=merge-duplicates" : "return=representation"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    public func upsert(values: Any, onConflict: String? = nil) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = "return=representation,resolution=merge-duplicates"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    public func update(values: Any) -> PostgrestFilterBuilder {
        method = "PATCH"
        headers["Prefer"] = "return=representation"
        body = values
        return PostgrestFilterBuilder(
            url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
            body: body
        )
    }

    public func delete() -> PostgrestFilterBuilder {
        method = "DELETE"
        headers["Prefer"] = "return=representation"
        return PostgrestFilterBuilder(
            url: url, queryParams: queryParams, headers: headers, schema: schema, method: method,
            body: body
        )
    }
}
