import Foundation

public class PostgrestFilterBuilder: PostgrestTransformBuilder {
    public enum Operator: String {
        case eq, neq, gt, gte, lt, lte, like, ilike, `is`, `in`, cs, cd, sl, sr, nxl, nxr, adj, ov, fts, plfts, phfts, wfts
    }

    public func not(column: String, operator op: Operator, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "not.\(op.rawValue).\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func or(filters: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: "or", value: "(\(filters))")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func eq(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "eq.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func neq(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "neq.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func gt(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "gt.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func gte(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "gte.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func lt(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "lt.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func lte(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "lte.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func like(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "like.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func ilike(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "ilike.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func `is`(column: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "is.\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func `in`(column: String, value: [String]) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "in.\(value.joined(separator: ","))")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func contains(column: String, value: Any) -> PostgrestFilterBuilder {
        if let str: String = value as? String {
            appendSearchParams(name: column, value: "cs.\(str)")
        } else if let arr: [String] = value as? [String] {
            appendSearchParams(name: column, value: "cs.\(arr.joined(separator: ","))")
        } else if let data: Data = try? JSONSerialization.data(withJSONObject: value, options: []), let json = String(data: data, encoding: .utf8) {
            appendSearchParams(name: column, value: "cs.\(json)")
        }
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func rangeLt(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "sl.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func rangeGt(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "sr.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func rangeGte(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "nxl.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func rangeLte(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "nxr.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func rangeAdjacent(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "adj.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func overlaps(column: String, value: Any) -> PostgrestFilterBuilder {
        if let str: String = value as? String {
            appendSearchParams(name: column, value: "ov.\(str)")
        } else if let arr: [String] = value as? [String] {
            appendSearchParams(name: column, value: "ov.\(arr.joined(separator: ","))")
        }
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func textSearch(column: String, range: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "adj.\(range)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func textSearch(column: String, query: String, config: String? = nil, type: TextSearchType? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "\(type?.rawValue ?? "")fts\(config ?? "").\(query)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func fts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "fts\(config ?? "").\(query)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func plfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "plfts\(config ?? "").\(query)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func phfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "phfts\(config ?? "").\(query)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func wfts(column: String, query: String, config: String? = nil) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "wfts\(config ?? "").\(query)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func filter(column: String, operator: String, value: String) -> PostgrestFilterBuilder {
        appendSearchParams(name: column, value: "\(`operator`).\(value)")
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }

    public func match(query: [String: String]) -> PostgrestFilterBuilder {
        query.forEach { key, value in
            appendSearchParams(name: key, value: "eq.\(value)")
        }
        return PostgrestFilterBuilder(url: url, method: method, headers: headers, schema: schema, body: body)
    }
}
