import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(postgrest_swiftTests.allTests),
    ]
}
#endif
