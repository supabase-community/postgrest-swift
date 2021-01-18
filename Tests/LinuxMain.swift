import XCTest

import postgrest_swiftTests

var tests = [XCTestCaseEntry]()
tests += postgrest_swiftTests.allTests()
XCTMain(tests)
