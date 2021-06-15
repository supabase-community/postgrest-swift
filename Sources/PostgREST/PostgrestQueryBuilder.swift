
class PostgrestQueryBuilder: PostgrestBuilder {
    override init(url: String, method: String? = nil, headers: [String: String] = [:], schema: String? = nil, body: [String: Any]? = nil) {
        super.init(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    func select(columns: String = "*") -> PostgrestFilterBuilder {
        method = "GET"
        var quoted = false
        let cleanedColumns = columns.compactMap { (char) -> String? in
            if char.isWhitespace, !quoted {
                return nil
            }
            if char == "\"" {
                quoted = !quoted
            }
            return String(char)
        }.reduce("", +)
        appendSearchParams(name: "select", value: cleanedColumns)
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    func insert(values: [String: Any], upsert: Bool = false, onConflict: String? = nil) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = upsert ? "return=representation,resolution=merge-duplicates" : "return=representation"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    func upsert(values: [String: Any], onConflict: String? = nil) -> PostgrestBuilder {
        method = "POST"
        headers["Prefer"] = "return=representation,resolution=merge-duplicates"
        if let onConflict = onConflict {
            appendSearchParams(name: "on_conflict", value: onConflict)
        }

        body = values
        return self
    }

    func update(values: [String: Any]) -> PostgrestFilterBuilder {
        method = "PATCH"
        headers["Prefer"] = "return=representation"
        body = values
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    func delete() -> PostgrestFilterBuilder {
        method = "DELETE"
        headers["Prefer"] = "return=representation"
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }
}
