@testable import FounDarwin
import XCTest

final class CommandTests: XCTestCase {
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
    
    // TODO:
    /*
    func testDownloadPackage() {
        downloadPackage(snapshotVersion: "swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a")
    }
    
    func testInstallPackage() {
        installPackage(snapshotVersion: "swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a")
    }
 
    func testRemovePkgFile() {
        
    }
     */
}
