#if !os(watchOS)
  import Foundation
  import SnapshotTesting
  import XCTest

  @testable import PostgREST

  #if canImport(FoundationNetworking)
    import FoundationNetworking
  #endif

  @MainActor
  final class BuildURLRequestTests: XCTestCase {
    let url = URL(string: "https://example.supabase.co")!

    struct TestCase {
      let name: String
      var record = false
      let build: @Sendable (PostgrestClient) throws -> PostgrestBuilder
    }

    func testBuildRequest() async throws {
      var runningTestCase: TestCase?

      let client = PostgrestClient(url: url, schema: nil)
//      { request in
//        struct SomeError: Error {}
//
//        guard let runningTestCase else {
//          XCTFail("Fetch called without a runningTestCase set.")
//          throw SomeError()
//        }
//
//        assertSnapshot(
//          matching: request,
//          as: .curl,
//          named: runningTestCase.name,
//          record: runningTestCase.record,
//          testName: "testBuildRequest()"
//        )
//
//        throw SomeError()
//      }

      let testCases: [TestCase] = [
        TestCase(name: "select all users where email ends with '@supabase.co'") { client in
          client.from("users")
            .select()
            .like(column: "email", value: "%@supabase.co")
        },
        TestCase(name: "insert new user") { client in
          try client.from("users")
            .insert(values: ["email": "johndoe@supabase.io"])
        },
        TestCase(name: "call rpc") { client in
          try client.rpc(fn: "test_fcn", params: ["KEY": "VALUE"])
        },
        TestCase(name: "call rpc without parameter") { client in
          try client.rpc(fn: "test_fcn")
        },
        TestCase(name: "test all filters and count") { client in
          var query = client.from("todos").select()

          for op in PostgrestFilterBuilder.Operator.allCases {
            query = query.filter(column: "column", operator: op, value: "Some value")
          }

          return query
        },
        TestCase(name: "test in filter") { client in
          client.from("todos").select().in(column: "id", value: [1, 2, 3])
        },
        TestCase(name: "test contains filter with dictionary") { client in
          client.from("users").select(columns: "name")
            .contains(column: "address", value: ["postcode": 90210])
        },
        TestCase(name: "test contains filter with array") { client in
          client.from("users")
            .select()
            .contains(column: "name", value: ["is:online", "faction:red"])
        },
        TestCase(name: "test upsert not ignoring duplicates") { client in
          client.from("users")
            .upsert(values: ["email": "johndoe@supabase.io"])
        },
        TestCase(name: "test upsert ignoring duplicates") { client in
          client.from("users")
            .upsert(values: ["email": "johndoe@supabase.io"], ignoreDuplicates: true)
        },
        TestCase(name: "query with + character") { client in
          client.from("users")
            .select()
            .eq(column: "id", value: "Cigányka-ér (0+400 cskm) vízrajzi állomás")
        },
        TestCase(name: "query with timestampz") { client in
          client.from("tasks")
            .select()
            .gt(column: "received_at", value: "2023-03-23T15:50:30.511743+00:00")
            .order(column: "received_at")
        }
      ]

      for testCase in testCases {
        runningTestCase = testCase
        let builder = try testCase.build(client)
//        builder.adaptRequest(head: false, count: nil)
        _ = try? await builder.execute()
      }
    }

    func testSessionConfiguration() {
      let client = PostgrestClient(url: url, schema: nil)
      let clientInfoHeader = client.configuration.headers["X-Client-Info"]
      XCTAssertNotNil(clientInfoHeader)
    }
  }
#endif
