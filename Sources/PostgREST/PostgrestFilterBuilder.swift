import Foundation

public class PostgrestFilterBuilder: PostgrestTransformBuilder {
    public enum Operator: String {
        case eq, neq, gt, gte, lt, lte, like, ilike, `is`, `in`, cs, cd, sl, sr, nxl, nxr, adj, ov, fts, plfts, phfts, wfts
    }

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
}
