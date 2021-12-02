import Foundation
import SnapshotTesting
import XCTest

@testable import PostgREST

final class BuildURLRequestTests: XCTestCase {
    let url = "https://example.supabase.co"

    struct TestCase {
        let name: String
        var record = false
        let build: (PostgrestClient) throws -> URLRequest
    }

    func testBuildURLRequest() throws {
        let client = PostgrestClient(url: url, schema: nil)

        let testCases: [TestCase] = [
            TestCase(name: "select all users where email ends with '@supabase.co'") { client in
                try client.from("users")
                    .select()
                    .like(column: "email", value: "%@supabase.co")
                    .buildURLRequest(head: false, count: nil)
            },
            TestCase(name: "insert new user") { client in
                try client.from("users")
                    .insert(values: ["email": "johndoe@supabase.io"])
                    .buildURLRequest(head: false, count: nil)
            },
            TestCase(name: "call rpc", build: { client in
                try client.rpc(fn: "test_fcn", parameters: ["KEY": "VALUE"])
                    .buildURLRequest(head: false, count: nil)
            })
        ]

        for testCase in testCases {
            let request = try testCase.build(client)
            assertSnapshot(matching: request, as: .curl, named: testCase.name, record: testCase.record)
        }
    }
}
