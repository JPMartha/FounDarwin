@testable import File
import XCTest
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

final class FileTests: XCTestCase {
    func currentDirectoryForTest() -> String? {
        #if os(Linux)
            let cwd = getcwd(nil, 0)
            guard let cd = cwd else {
                free(cwd)
                XCTFail("Cannot getcwd.")
                return nil
            }
        #else
            let cwd = getcwd(nil, Int(PATH_MAX))
            guard let cd = cwd else {
                free(cwd)
                XCTFail("Cannot getcwd.")
                return nil
            }
        #endif
        
        guard let path = String(validatingUTF8: cd) else {
            XCTFail("Cannot validatingUTF8.")
            return nil
        }
        return path
    }
    
    func testIsAccessible() {
        let path = currentDirectoryForTest()
        let testFile = "Package.swift"
        #if os(Linux)
            File.isAccessible(name: testFile)
        #else
            File.isAccessible(path: "\(path)/\(testFile)")
        #endif
    }
}

extension FileTests {
    static var allTests : [(String, (FileTests) -> () throws -> Void)] {
        return [
                   ("testIsAccessible", testIsAccessible),
        ]
    }
}
