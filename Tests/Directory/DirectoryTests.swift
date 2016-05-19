@testable import Directory
import XCTest

final class DirectoryTests: XCTestCase {
    
    // FIXME:
    /*
    private var pwd = String()
    
    override func setUp() {
        super.setUp()
        
        let fp = popen("echo $PWD", "r")
        
        // FIXME: Hard-Coding
        let bufferSize = 4096
        var buffer = [Int8](repeating: 0, count: bufferSize + 1)
        fgets(&buffer, Int32(bufferSize), fp)
        pclose(fp)

        pwd = String(validatingUTF8: buffer)!
    }
     */
    
    func testCurrentDirectoryPath() {
        var cd: String
        do {
            cd = try currentDirectoryPath()
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotGetCurrentDirectory)
            return
        }
        guard !cd.isEmpty else {
            XCTAssertThrowsError(DirectoryError.CannotGetCurrentDirectory)
            return
        }
        
        #if os(Linux)
            print(cd)
        #else
        let fp = popen("echo $PWD", "r")
        
        // FIXME: Hard-Coding
        let bufferSize = 4096
        var buffer = [Int8](repeating: 0, count: bufferSize + 1)
        fgets(&buffer, Int32(bufferSize), fp)
        guard let string = String(validatingUTF8: buffer) else {
            XCTFail()
            return
        }
        pclose(fp)
        
        XCTAssertEqual(String(string.characters.dropLast()), cd)
        #endif
    }
    
    /*
    func testChangeDirectory() {
        // TODO:
        do {
            try changeDirectory(path: "\(pwd)")
        } catch {
            XCTFail()
            return
        }
    }
    
    func testCreateDirectory() {
        // TODO:
        do {
            try createDirectory(path: "\(pwd)/test")
        } catch {
            XCTFail()
            return
        }
        XCTAssertTrue(access("\(pwd)/test", F_OK) == 0)
    }
    */
}

extension DirectoryTests {
    static var allTests : [(String, (DirectoryTests) -> () throws -> Void)] {
        return [
                   ("testCurrentDirectoryPath", testCurrentDirectoryPath),
        ]
    }
}
