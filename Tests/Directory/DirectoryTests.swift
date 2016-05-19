@testable import Directory
import XCTest

final class DirectoryTests: XCTestCase {
    private var currentDirectory = String()
    
    override func setUp() {
        super.setUp()
        
        do {
            currentDirectory = try currentDirectoryPath()
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotGetCurrentDirectory)
            return
        }
        guard !currentDirectory.isEmpty else {
            XCTAssertThrowsError(DirectoryError.CannotGetCurrentDirectory)
            return
        }
    }
    
    func testCurrentDirectoryPath() {
        #if os(Linux)
            print("CurrentDirectoryPath: \(currentDirectory)")
        #else
            let fp = popen("echo $PWD", "r")
            
            // FIXME: Hard-Coding
            let bufferSize = 4096
            var buffer = [Int8](repeating: 0, count: bufferSize + 1)
            fgets(&buffer, Int32(bufferSize), fp)
            guard let cd = String(validatingUTF8: buffer) else {
                XCTFail()
                return
            }
            pclose(fp)
            
            XCTAssertEqual(String(cd.characters.dropLast()), currentDirectory)
        #endif
    }
    
    func testChangeDirectory() {
        do {
            try createDirectory(path: "\(currentDirectory)/test")
        } catch {
            XCTFail()
            return
        }
        #if os(Linux)
            // TODO:
        #else
            XCTAssertTrue(access("\(currentDirectory)/test", F_OK) == 0)
        #endif

        do {
            try changeDirectory(path: "\(currentDirectory)/test")
        } catch {
            XCTFail("Cannot changeDirectory")
            return
        }
    }
}

extension DirectoryTests {
    static var allTests : [(String, (DirectoryTests) -> () throws -> Void)] {
        return [
                   ("testCurrentDirectoryPath", testCurrentDirectoryPath),
                   ("testChangeDirectory", testChangeDirectory),
        ]
    }
}
