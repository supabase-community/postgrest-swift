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

```swift
import Foundation
import PostgREST

let supabaseUrl = ""
let supabaseKey = ""

var database = PostgrestClient(
    url: "\(supabaseUrl)/rest/v1",
    headers: ["apikey": supabaseKey],
    schema: "public")

let semaphore = DispatchSemaphore(value: 0)

struct Todo: Codable {
    var id: Int?
    var task: String?
    var completed: Bool?
}

database.from("todo").select().execute { result in
    switch result {
    case let .success(response):
        do {
            let todos = try response.decoded(to: [Todo].self)
            print(todos)
        } catch {
            print(error.localizedDescription)
        }
    case let .failure(error):
        print(error.localizedDescription)
    }
}

do {
    let todo = Todo(task: "fix some issues in postgrest-swift", completed: true)
    let jsonData: Data = try JSONEncoder().encode(todo)

    database.from("todo").insert(values: jsonData).execute { result in
        switch result {
        case let .success(response):
            do {
                let todos = try response.decoded(to: [Todo].self)
                print(todos)
            } catch {
                print(error.localizedDescription)
            }
        case let .failure(error):
            print(error.localizedDescription)
        }
    }

} catch {
    print(error.localizedDescription)
}

semaphore.wait()
```

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

-   Fork the repo on GitHub
-   Clone the project to your own machine
-   Commit changes to your own branch
-   Push your work back up to your fork
-   Submit a Pull request so that we can review your changes and merge

## License

This repo is liscenced under MIT.
