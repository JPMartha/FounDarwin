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
            XCTFail("Failed executeCommand")
            return
        }
        print(ls)
        XCTAssertNotNil(ls)
    }
    
    func testDownloadAndInstallDevelopmentSnapshots() {
        downloadDevelopmentSnapshots(version: "swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a")
        do {
            try installDevelopmentSnapshots(version: "swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a")
        } catch {
            XCTFail()
        }
        removePkgFile(snapshotVersion: "swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a")
    }
    
    func testDownloadAndInstallPreview1Snapshots() {
        downloadPreview1Snapshots(version: "swift-3.0-preview-1-SNAPSHOT-2016-05-31-a")
        do {
            try installPreview1Snapshots(version: "swift-3.0-preview-1-SNAPSHOT-2016-05-31-a")
        } catch {
            XCTFail()
        }
        removePkgFile(snapshotVersion: "swift-3.0-preview-1-SNAPSHOT-2016-05-31-a")
    }
#endif
}

extension CommandTests {
#if os(Linux)
#else
    static var allTests : [(String, (CommandTests) -> () throws -> Void)] {
        return [
                   ("testExecuteCommandNil", testExecuteCommandNil),
                   ("testExecuteCommandNotNil", testExecuteCommandNotNil),
                   ("testDownloadAndInstallDevelopmentSnapshots", testDownloadAndInstallDevelopmentSnapshots),
                   ("testDownloadAndInstallPreview1Snapshots", testDownloadAndInstallPreview1Snapshots),
        ]
    }
#endif
}
