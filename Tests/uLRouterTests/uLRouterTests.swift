import XCTest
@testable import uLRouter

final class uLRouterTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(uLRouter().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
