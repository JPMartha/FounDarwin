import XCTest
@testable import FTDarwin

class FTDarwinTests: XCTestCase {

	func testExample() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	}

}
extension FTDarwinTests {
	static var allTests : [(String, FTDarwinTests -> () throws -> Void)] {
		return [
			("testExample", testExample),
		]
	}
}
