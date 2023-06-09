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
      let build: (PostgrestClient) -> PostgrestBuilder
    }

    func testBuildRequest() async throws {
      let client = PostgrestClient(url: url, schema: nil)

      let testCases: [TestCase] = [
        TestCase(name: "select all users where email ends with '@supabase.co'") { client in
          client.from("users")
            .select()
            .like(column: "email", value: "%@supabase.co")
        },
        TestCase(name: "insert new user") { client in
          client.from("users")
            .insert(values: ["email": "johndoe@supabase.io"])
        },
        TestCase(name: "upsert user") { client in
          client.from("users")
            .upsert(
              values: ["id": "69b3f37a-ff3b-4c66-a4ab-038b70e5c762", "name": "John Doe"],
              returning: .minimal
            )
        },
        TestCase(name: "call rpc") { client in
          client.rpc(fn: "test_fcn", params: ["KEY": "VALUE"])
        },
        TestCase(name: "call rpc without parameter") { client in
          client.rpc(fn: "test_fcn")
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
      ]

      for testCase in testCases {
        client.fetch = { request in
          assertSnapshot(
            matching: request,
            as: .curl,
            named: testCase.name,
            record: testCase.record,
            testName: "testBuildRequest()"
          )

          struct SomeError: Error {}
          throw SomeError()
        }

        let builder = testCase.build(client)
        builder.adaptRequest(head: false, count: nil)
        _ = try? await builder.execute()
      }
    }

    func testSessionConfiguration() {
//      let client = PostgrestClient(url: url, schema: nil)
//      let clientInfoHeader = client.api.configuration.sessionConfiguration
//        .httpAdditionalHeaders?["X-Client-Info"]
//      XCTAssertNotNil(clientInfoHeader)
    }
  }
#endif
