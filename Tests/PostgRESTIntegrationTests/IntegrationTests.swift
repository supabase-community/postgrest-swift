import PostgREST
import XCTest

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

@available(iOS 15.0.0, macOS 12.0.0, tvOS 13.0, *)
final class IntegrationTests: XCTestCase {
  func testIntegration() async throws {
    if ProcessInfo.processInfo.environment["INTEGRATION_TESTS"] == nil {
      throw XCTSkip("INTEGRATION_TESTS not defined.")
    }

    let client = PostgrestClient(
      url: "http://localhost:54321/rest/v1",
      headers: [
        "apikey":
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24ifQ.625_WdcF3KHqz5amU0x2X5WWHP-OEs_4qj0ssLNHzTs"
      ],
      schema: "public"
    )

    var todos = try await client.from("todo").select().execute().decoded(to: [Todo].self)
    XCTAssertEqual(todos, [])

    let insertedTodo = try await client.from("todo")
      .insert(values: NewTodo(description: "Implement integration tests for postgrest-swift"))
      .execute()
      .decoded(to: [Todo].self)[0]

    todos = try await client.from("todo").select().execute().decoded()
    XCTAssertEqual(todos, [insertedTodo])

    let insertedTodos = try await client.from("todo")
      .insert(values: [
        NewTodo(description: "Make supabase swift libraries production ready"),
        NewTodo(description: "Drink some coffee"),
      ])
      .execute()
      .decoded(to: [Todo].self)

    todos = try await client.from("todo").select().execute().decoded()
    XCTAssertEqual(todos, [insertedTodo] + insertedTodos)

    let drinkCoffeeTodo = insertedTodos[1]
    let updatedTodo = try await client.from("todo")
      .update(values: ["is_complete": true])
      .eq(column: "id", value: drinkCoffeeTodo.id.uuidString)
      .execute()
      .decoded(to: [Todo].self)[0]
    XCTAssertTrue(updatedTodo.isComplete)

    let completedTodos = try await client.from("todo")
      .select()
      .eq(column: "is_complete", value: true)
      .execute()
      .decoded(to: [Todo].self)
    XCTAssertEqual(completedTodos, [updatedTodo])

    try await client.from("todo").delete().eq(column: "is_complete", value: true).execute()
    todos = try await client.from("todo").select().execute().decoded(to: [Todo].self)
    XCTAssertTrue(completedTodos.allSatisfy { todo in !todos.contains(todo) })
  }
}
