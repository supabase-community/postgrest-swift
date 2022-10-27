#if !os(watchOS)
  import Foundation
  import SnapshotTesting
  import XCTest

  @testable import PostgREST

  #if canImport(FoundationNetworking)
    import FoundationNetworking
  #endif

  final class BuildURLRequestTests: XCTestCase {
    let url = "https://example.supabase.co"

    struct TestCase {
      let name: String
      var record = false
      let build: (PostgrestClient) -> PostgrestBuilder
    }

    func testBuildRequest() throws {
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
      ]

      for testCase in testCases {
        let builder = testCase.build(client)
        builder.adaptRequest(head: false, count: nil)
        let request = builder.request
        assertSnapshot(matching: request, as: .dump, named: testCase.name, record: testCase.record)
      }
    }
  }
#endif
