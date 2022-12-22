import PostgREST
import XCTest

struct Todo: Codable, Hashable {
  let id: UUID
  var description: String
  var isComplete: Bool
  let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case description
    case isComplete = "is_complete"
    case createdAt = "created_at"
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
  let client = PostgrestClient(
    url: URL(string: "http://localhost:54321/rest/v1")!,
    headers: [
      "apikey":
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0",
    ],
    schema: "public"
  )

  override func setUp() async throws {
    try await super.setUp()

//    try XCTSkipUnless(
//      ProcessInfo.processInfo.environment["INTEGRATION_TESTS"] != nil,
//      "INTEGRATION_TESTS not defined."
//    )

    // Run fresh test by deleting all todos.
    try await client.from("todo").delete().execute()
  }

  func testIntegration() async throws {
    var todos = try await client.from("todo").select().execute(returning: [Todo].self).value
    XCTAssertEqual(todos, [])

    let insertedTodo = try await client.from("todo")
      .insert(
        values: NewTodo(description: "Implement integration tests for postgrest-swift"),
        returning: .representation
      )
      .single()
      .execute(returning: Todo.self)
      .value

    todos = try await client.from("todo").select().execute().value
    XCTAssertEqual(todos, [insertedTodo])

    let insertedTodos = try await client.from("todo")
      .insert(
        values: [
          NewTodo(description: "Make supabase swift libraries production ready"),
          NewTodo(description: "Drink some coffee"),
        ],
        returning: .representation
      )
      .execute(returning: [Todo].self)
      .value

    todos = try await client.from("todo").select().execute().value
    XCTAssertEqual(todos, [insertedTodo] + insertedTodos)

    let drinkCoffeeTodo = insertedTodos[1]
    let updatedTodo = try await client.from("todo")
      .update(values: ["is_complete": true])
      .eq(column: "id", value: drinkCoffeeTodo.id.uuidString)
      .single()
      .execute(returning: Todo.self)
      .value
    XCTAssertTrue(updatedTodo.isComplete)

    let completedTodos = try await client.from("todo")
      .select()
      .eq(column: "is_complete", value: true)
      .execute(returning: [Todo].self)
      .value
    XCTAssertEqual(completedTodos, [updatedTodo])

    try await client.from("todo").delete().eq(column: "is_complete", value: true).execute()
    todos = try await client.from("todo").select().execute().value
    XCTAssertTrue(completedTodos.allSatisfy { todo in !todos.contains(todo) })
  }
}
