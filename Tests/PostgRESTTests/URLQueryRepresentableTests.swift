import PostgREST
import XCTest

final class URLQueryRepresentableTests: XCTestCase {
  func testArray() {}

  func testDictionary() {
    let dictionary = ["postalcode": 90210]
    let queryValue = dictionary.queryValue
    XCTAssertEqual(queryValue, "{\"postalcode\":90210}")
  }
}
