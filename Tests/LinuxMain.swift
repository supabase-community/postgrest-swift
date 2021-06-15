import XCTest

import PostgRESTTests

var tests = [XCTestCaseEntry]()
tests += PostgRESTTests.allTests()
XCTMain(tests)
