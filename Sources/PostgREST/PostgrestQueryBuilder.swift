public final class PostgrestQueryBuilder: PostgrestBuilder {
  /// Performs a vertical filtering with SELECT.
  /// - Parameters:
  ///   - columns: The columns to retrieve, separated by commas.
  ///   - head: When set to true, select will void data.
  ///   - count: Count algorithm to use to count rows in a table.
  ///   - foreignTable: The foreign table or view name to query.
  ///   - foreignTableColum: The columns associated with to retrieve, separated by commas
  public func select(
    columns: String = "*",
    foreignTable: String? = nil,
    foreignTableColum: String = "*",
    head: Bool = false,
    count: CountOption? = nil
  ) -> PostgrestFilterBuilder {
    method = "GET"
    // remove whitespaces except when quoted.
    var quoted = false
    var selectQueryValue = ""
    let cleanedColumns = columns.compactMap { char -> String? in
      if char.isWhitespace, !quoted {
        return nil
      }
      if char == "\"" {
        quoted = !quoted
      }
      return String(char)
    }
      .joined(separator: "")
    selectQueryValue += cleanedColumns
    if let foreignTable = foreignTable {
      let cleanedForeignTable = foreignTable.compactMap { char -> String? in
        if char.isWhitespace, !quoted {
          return nil
        }
        if char == "\"" {
          quoted = !quoted
        }
        return String(char)
      }
        .joined(separator: "")
      
      let cleanedForeignTableColum = foreignTableColum.compactMap { char -> String? in
        if char.isWhitespace, !quoted {
          return nil
        }
        if char == "\"" {
          quoted = !quoted
        }
        return String(char)
      }
        .joined(separator: "")
      selectQueryValue = "\(cleanedForeignTable)(\(cleanedForeignTableColum))"
    }
    appendSearchParams(name: "select", value: selectQueryValue)
    if let count = count {
      headers["Prefer"] = "count=\(count.rawValue)"
    }
    if head {
      method = "HEAD"
    }
    return PostgrestFilterBuilder(self)
  }
    
  /// Performs a vertical filtering with SELECT.
  /// - Parameters:
  ///   - columns: The columns to retrieve, separated by commas.
  ///   - head: When set to true, select will void data.
  ///   - count: Count algorithm to use to count rows in a table.
  public func select(
    columns: String = "*",
    head: Bool = false,
    count: CountOption? = nil
  ) -> PostgrestFilterBuilder {
    method = "GET"
    // remove whitespaces except when quoted.
    var quoted = false
    let cleanedColumns = columns.compactMap { char -> String? in
      if char.isWhitespace, !quoted {
        return nil
      }
      if char == "\"" {
        quoted = !quoted
      }
      return String(char)
    }
    .joined(separator: "")
    appendSearchParams(name: "select", value: cleanedColumns)
    if let count = count {
      headers["Prefer"] = "count=\(count.rawValue)"
    }
    if head {
      method = "HEAD"
    }
    return PostgrestFilterBuilder(self)
  }

  public func insert<U: Encodable>(
    values: U,
    returning: PostgrestReturningOptions? = nil,
    count: CountOption? = nil
  ) -> PostgrestFilterBuilder {
    method = "POST"
    var prefersHeaders: [String] = []
    if let returning = returning {
      prefersHeaders.append("return=\(returning.rawValue)")
    }
    body = values
    if let count = count {
      prefersHeaders.append("count=\(count.rawValue)")
    }
    if let prefer = headers["Prefer"] {
      prefersHeaders.insert(prefer, at: 0)
    }
    if prefersHeaders.isEmpty == false {
      headers["Prefer"] = prefersHeaders.joined(separator: ",")
    }

    // TODO: How to do this in Swift?
    // if (Array.isArray(values)) {
    //     const columns = values.reduce((acc, x) => acc.concat(Object.keys(x)), [] as string[])
    //     if (columns.length > 0) {
    //         const uniqueColumns = [...new Set(columns)].map((column) => `"${column}"`)
    //         this.url.searchParams.set('columns', uniqueColumns.join(','))
    //     }
    // }

    return PostgrestFilterBuilder(self)
  }

  /// Performs an UPSERT into the table.
  /// - Parameters:
  ///   - values: The values to insert.
  ///   - onConflict: By specifying the `on_conflict` query parameter, you can make UPSERT work on a
  /// column(s) that has a unique constraint.
  ///   - returning: By default the new record is returned. Set this to `minimal` if you don't need
  /// this value.
  ///   - count: Count algorithm to use to count rows in a table.
  ///   - ignoreDuplicates: Specifies if duplicate rows should be ignored and not inserted.
  public func upsert<U: Encodable>(
    values: U,
    onConflict: String? = nil,
    returning: PostgrestReturningOptions = .representation,
    count: CountOption? = nil,
    ignoreDuplicates: Bool = false
  ) -> PostgrestFilterBuilder {
    method = "POST"
    var prefersHeaders = [
      "resolution=\(ignoreDuplicates ? "ignore" : "merge")-duplicates",
      "return=\(returning.rawValue)",
    ]
    if let onConflict = onConflict {
      appendSearchParams(name: "on_conflict", value: onConflict)
    }
    body = values
    if let count = count {
      prefersHeaders.append("count=\(count.rawValue)")
    }
    if let prefer = headers["Prefer"] {
      prefersHeaders.insert(prefer, at: 0)
    }
    if prefersHeaders.isEmpty == false {
      headers["Prefer"] = prefersHeaders.joined(separator: ",")
    }
    return PostgrestFilterBuilder(self)
  }

  /// Performs an UPDATE on the table.
  /// - Parameters:
  ///   - values: The values to update.
  ///   - returning: By default the updated record is returned. Set this to `minimal` if you don't
  /// need this value.
  ///   - count: Count algorithm to use to count rows in a table.
  public func update<U: Encodable>(
    values: U,
    returning: PostgrestReturningOptions = .representation,
    count: CountOption? = nil
  ) -> PostgrestFilterBuilder {
    method = "PATCH"
    var preferHeaders = ["return=\(returning.rawValue)"]
    body = values
    if let count = count {
      preferHeaders.append("count=\(count.rawValue)")
    }
    if let prefer = headers["Prefer"] {
      preferHeaders.insert(prefer, at: 0)
    }
    if preferHeaders.isEmpty == false {
      headers["Prefer"] = preferHeaders.joined(separator: ",")
    }
    return PostgrestFilterBuilder(self)
  }

  /// Performs a DELETE on the table.
  /// - Parameters:
  ///   - returning: By default the deleted rows are returned. Set this to `minimal` if you don't
  /// need this value.
  ///   - count: Count algorithm to use to count rows in a table.
  public func delete(
    returning: PostgrestReturningOptions = .representation,
    count: CountOption? = nil
  ) -> PostgrestFilterBuilder {
    method = "DELETE"
    var preferHeaders = ["return=\(returning.rawValue)"]
    if let count = count {
      preferHeaders.append("count=\(count.rawValue)")
    }
    if let prefer = headers["Prefer"] {
      preferHeaders.insert(prefer, at: 0)
    }
    if preferHeaders.isEmpty == false {
      headers["Prefer"] = preferHeaders.joined(separator: ",")
    }
    return PostgrestFilterBuilder(self)
  }
}
