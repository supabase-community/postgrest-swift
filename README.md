# Postgrest Swift

## Installation

Swift client for [PostgREST](https://postgrest.org). The goal of this library is to make an "ORM-like" restful interface. 

### Swift Package Manager

Add `postgrest-swift` as a dependency to your `Package.swift` file. For more information, please see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```swift
.package(url: "https://github.com/supabase/postgrest-swift", from: "0.1.0")
```

### Supabase

You can also install the [ `supabase-swift`](https://github.com/supabase/supabase-swift) package to use the entire supabase library.

## Usage

Query todo table for all completed todos.
```swift
let client = PostgrestClient(url: "https://example.supabase.co", schema: nil)

do {
   let query = try client.from("todos")
                           .select()
                           .eq(column: "isDone", value: "true")
   try query.execute { [weak self] (results) in
       guard let self = self else { return }

       // Handle results
   }
} catch {
   print("Error querying for todos: \(error)")
}
```

Insert a todo into the database.
```swift
let client = PostgrestClient(url: "https://example.supabase.co", schema: nil)

struct Todo: Codable {
    var id: UUID = UUID()
    var label: String
    var isDone: Bool = false
}

let todo = Todo(label: "Example todo!")

do {
    let jsonData: Data = try JSONEncoder().encode(todo)
    let jsonDict: [String: Any] = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments))
    
    try client.from("todos")    
        .insert(values: jsonDict)
        .execute { results in
        // Handle response
    }
} catch {
   print("Error inserting the todo: \(error)")
}
```

For more query examples visit [the Javascript docs](https://supabase.io/docs/reference/javascript/select) to learn more. The API design is a near 1:1 match.

Execute an RPC
```swift
let client = PostgrestClient(url: "https://example.supabase.co", schema: nil)

do {
    try client.rpc(fn: "testFunction", parameters: nil).execute { result in
        // Handle result
    }
} catch {
   print("Error executing the RPC: \(error)")
}
```

## Auth

You can add authentication to the databases requests by using the `client.headers` property. For example to add a `Bearer` auth header, simply set the headers dictionary to:
```swift
let client = PostgrestClient(url: "https://example.supabase.co",
                             headers: ["Bearer": "{ Insert Token Here }"]
                             schema: nil)
```
All requests made using this client will be sent with the `Bearer Token` header.

## Contributing

- Fork the repo on GitHub
- Clone the project to your own machine
- Commit changes to your own branch
- Push your work back up to your fork
- Submit a Pull request so that we can review your changes and merge

## License

This repo is liscenced under MIT.
