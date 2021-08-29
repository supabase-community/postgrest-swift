import Foundation

public class PostgrestFilterBuilder: PostgrestTransformBuilder {
    public enum Operator: String {
        case eq, neq, gt, gte, lt, lte, like, ilike, `is`, `in`, cs, cd, sl, sr, nxl, nxr, adj, ov, fts, plfts, phfts, wfts
    }
    
    // MARK: - Filters

    public func not(column: String, operator op: Operator, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "not.\(op.rawValue).\(value)")
        return self
    }

    public func or(filters: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: "or", value: "(\(filters))")
        return self
    }

    public func eq(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "eq.\(value)")
        return self
    }

    public func neq(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "neq.\(value)")
        return self
    }

    public func gt(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "gt.\(value)")
        return self
    }

    public func gte(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "gte.\(value)")
        return self
    }

    public func lt(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "lt.\(value)")
        return self
    }

    public func lte(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "lte.\(value)")
        return self
    }

    public func like(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "like.\(value)")
        return self
    }

    public func ilike(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "ilike.\(value)")
        return self
    }

    public func `is`(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "is.\(value)")
        return self
    }

    public func `in`(column: String, value: [String]) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "in.\(value.joined(separator: ","))")
        return self
    }

    public func contains(column: String, value: Any) -> PostgrestFilterBuilder {
        if let str: String = value as? String {
            appendSearchParams(name: column, value: "cs.\(str)")
        } else if let arr: [String] = value as? [String] {
            appendSearchParams(name: column, value: "cs.\(arr.joined(separator: ","))")
        } else if let data: Data = try? JSONSerialization.data(withJSONObject: value, options: []), let json = String(data: data, encoding: .utf8) {
            appendSearchParams(name: column, value: "cs.\(json)")
        }
        return self
    }

    public func rangeLt(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "sl.\(range)")
        return self
    }

    public func rangeGt(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "sr.\(range)")
        return self
    }

    public func rangeGte(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "nxl.\(range)")
        return self
    }

    public func rangeLte(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "nxr.\(range)")
        return self
    }

    public func rangeAdjacent(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "adj.\(range)")
        return self
    }

    public func overlaps(column: String, value: Any) -> PostgrestFilterBuilder {
        if let str: String = value as? String {
            appendSearchParams(name: column, value: "ov.\(str)")
        } else if let arr: [String] = value as? [String] {
            appendSearchParams(name: column, value: "ov.\(arr.joined(separator: ","))")
        }
        return self
    }

    public func textSearch(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "adj.\(range)")
        return self
    }

    public func textSearch(
        column: String, query: String, config: String? = nil, type: TextSearchType? = nil
    ) -> PostgrestFilterBuilder {
        appendSearchParams(
            name: column, value: "\(type?.rawValue ?? "")fts\(config ?? "").\(query)"
        )
        return self
    }

    public func fts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "fts\(config ?? "").\(query)")
        return self
    }

    public func plfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "plfts\(config ?? "").\(query)")
        return self
    }

    public func phfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "phfts\(config ?? "").\(query)")
        return self
    }

    public func wfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "wfts\(config ?? "").\(query)")
        return self
    }

    public func filter(column: String, operator: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "\(`operator`).\(value)")
        return self
    }

    public func match(query: [String: String]) -> PostgrestFilterBuilder {
        query.forEach { key, value in
            appendSearchParams(name: key, value: "eq.\(value)")
        }
        return self
    }
    
    // MARK: - Modifiers
    
    /// Limits the number of results returned by the query
    /// https://supabase.io/docs/reference/javascript/limit
    /// - Parameter limit: Number of results to return
    public func limit(_ limit: Int) -> PostgrestFilterBuilder {
        appendSearchParams(name: "limit", value: String(limit))
        return self
    }
    
    /// Offsets the query by a number of results. Useful for paginating queries
    /// https://postgrest.org/en/v8.0/api.html#limits-and-pagination
    /// - Parameter offset: Number of results to offset by
    public func offset(_ offset: Int) -> PostgrestFilterBuilder {
        appendSearchParams(name: "offset", value: String(offset))
        return self
    }
    
    /// Limits a query to a range of values
    /// Eg: 15 - 30 gets the results from 15 -> 30
    /// https://supabase.io/docs/reference/javascript/range
    /// - Parameters:
    ///   - offset: The start offset
    ///   - range: The last index of the range
    public func range(_ offset: Int, _ range: Int) -> PostgrestFilterBuilder {
        return self.offset(offset).limit(range - offset)
    }
    
    /// Returns only a single result
    /// https://supabase.io/docs/reference/javascript/single
    public func single() -> PostgrestFilterBuilder {
        return self.limit(1)
    }
    
    /// Orders the results by a column
    /// https://postgrest.org/en/v8.0/api.html#ordering
    /// - Parameters:
    ///   - column: Column to order by
    ///   - desc: Toggle descending order
    public func order(_ column: String, desc: Bool = false) -> PostgrestFilterBuilder {
        appendSearchParams(name: "order", value: desc ? "\(column).desc" : "\(column).asc")
        return self
    }
}
