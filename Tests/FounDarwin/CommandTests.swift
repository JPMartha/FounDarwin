@testable import FounDarwin
import XCTest

final class CommandTests: XCTestCase {
#if os(Linux)
#else
    func testExecuteCommandNil() {
        let export = executeCommand(argments: ["export", "PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:\"${PATH}\""])
        XCTAssertNil(export)
    }
    
    func testExecuteCommandNotNil() {
        guard let ls = executeCommand(argments: ["ls"]) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(ls)
    }
#endif
}
