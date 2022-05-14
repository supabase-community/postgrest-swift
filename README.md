# Postgrest Swift

## Installation

Swift client for [PostgREST](https://postgrest.org). The goal of this library is to make an "ORM-like" restful interface. 

### Swift Package Manager

Add `postgrest-swift` as a dependency to your `Package.swift` file. For more information, please see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```swift
.package(url: "https://github.com/supabase/postgrest-swift", .exact("0.0.2"))
```

### Supabase

You can also install the [ `supabase-swift`](https://github.com/supabase/supabase-swift) package to use the entire supabase library.

## Usage

```swift
import Foundation
import PostgREST

let supabaseUrl = ""
let supabaseKey = ""

var database = PostgrestClient(
    url: "\(supabaseUrl)/rest/v1",
    headers: ["apikey": supabaseKey],
    schema: "public")

struct Todo: Codable, Hashable {
  let id: UUID
  var description: String
  var isComplete: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case description
    case isComplete = "is_complete"
  }
}

struct NewTodo: Codable, Hashable {
  var description: String
  var isComplete: Bool = false

  enum CodingKeys: String, CodingKey {
    case description
    case isComplete = "is_complete"
  }
}

// Get todos
var todos = try await client
    .from("todo")
    .select()
    .execute()
    .decoded(to: [Todo].self)

// Insert a todo
let insertedTodo = try await client.from("todo")
    .insert(values: NewTodo(description: "Implement integration tests for postgrest-swift"))
    .execute()
    .decoded(to: [Todo].self)[0]

// Insert multiple todos
let insertedTodos = try await client.from("todo")
    .insert(values: [
        NewTodo(description: "Make supabase swift libraries production ready"),
        NewTodo(description: "Drink some coffee"),
    ])
    .execute()
    .decoded(to: [Todo].self)

```

## Contributing

-  Fork the repo on GitHub
-  Clone the project to your own machine
-  Commit changes to your own branch
-  Push your work back up to your fork
-  Submit a Pull request so that we can review your changes and merge

## License

This repo is liscenced under MIT.
