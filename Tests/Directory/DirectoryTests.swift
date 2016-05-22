@testable import Directory
import XCTest
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

final class DirectoryTests: XCTestCase {
    func testCurrentDirectory() {
        var cd = String()
        do {
            cd = try currentDirectoryPath()
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotGetCurrentDirectory)
            return
        }
        
        guard let path = String(validatingUTF8: cd) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(path)
        print("currentDirectoryPath: \(path)")
    }
    
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
    
    func testChangeDirectory() {
        guard let path1 = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print("currentDirectoryPath: \(path1)")
        
        do {
            try changeDirectory(path: "\(path1)/.build")
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
        
        // TODO: Verify
        
        guard let path2 = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print("currentDirectoryPath: \(path2)")
        
        // It is necessary for making a success of the other tests
        //   to change working directory into path1.
        
        do {
            try changeDirectory(path: path1)
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
    }
    
    func testCreateDirectory() {
        guard let path = currentDirectoryForTest() else {
            XCTFail("Failed: currentDirectoryForTest")
            return
        }
        print(path)
        let testCreateDirectoryName = "testCreateDirectory"
        
        do {
            try createDirectory(path: "\(path)/\(testCreateDirectoryName)")
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotCreateDirectory)
            return
        }
        
        #if os(Linux)
            guard chdir(path) == 0 else {
                XCTFail("Cannot chdir")
                return
            }
            XCTAssertEqual(access(testCreateDirectoryName, F_OK), 0)
        #else
            XCTAssertEqual(access("\(path)/\(testCreateDirectoryName)", F_OK), 0)
        #endif
        
        rmdir("\(path)/\(testCreateDirectoryName)")
    }
    
    func testIsAccessibleDirectory() {
        guard let path = currentDirectoryForTest() else {
            XCTFail("Failed: currentDirectoryForTest")
            return
        }
        print(path)
        
        let testAccessibleDirectoryName = "testAccessibleDirectory"
        #if os(Linux)
            XCTAssertFalse(isAccessibleDirectory(path: testAccessibleDirectoryName))
        #else
            XCTAssertFalse(isAccessibleDirectory(path: "\(path)/\(testAccessibleDirectoryName)"))
        #endif
        
        guard mkdir("\(path)/\(testAccessibleDirectoryName)", S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
            XCTFail("Cannot mkdir")
            return
        }
        
        #if os(Linux)
            XCTAssertTrue(isAccessibleDirectory(path: testAccessibleDirectoryName))
        #else
            XCTAssertTrue(isAccessibleDirectory(path: "\(path)/\(testAccessibleDirectoryName)"))
        #endif
        
        rmdir("\(path)/\(testAccessibleDirectoryName)")
        #if os(Linux)
            XCTAssertFalse(isAccessibleDirectory(path: testAccessibleDirectoryName))
        #else
            XCTAssertFalse(isAccessibleDirectory(path: "\(path)/\(testAccessibleDirectoryName)"))
        #endif
    }
    
    func testRemoveDirectory() {
        guard let path = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print(path)
        
        let testRemoveDirectoryName = "testRemoveDirectory"
        guard mkdir("\(path)/\(testRemoveDirectoryName)", S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
            XCTFail()
            return
        }
        
        #if os(Linux)
            XCTAssertEqual(access(testRemoveDirectoryName, F_OK), 0)
        #else
            XCTAssertEqual(access("\(path)/\(testRemoveDirectoryName)", F_OK), 0)
        #endif
        
        removeDirectory(path: "\(path)/\(testRemoveDirectoryName)")
        
        #if os(Linux)
            XCTAssertNotEqual(access(testRemoveDirectoryName, F_OK), 0)
        #else
            XCTAssertNotEqual(access("\(path)/\(testRemoveDirectoryName)", F_OK), 0)
        #endif
    }
}

extension DirectoryTests {
    static var allTests : [(String, (DirectoryTests) -> () throws -> Void)] {
        return [
                   ("testCurrentDirectory", testCurrentDirectory),
                   ("testChangeDirectory", testChangeDirectory),
                   ("testCreateDirectory", testCreateDirectory),
                   ("testIsAccessibleDirectory", testIsAccessibleDirectory),
                   ("testRemoveDirectory", testRemoveDirectory),
        ]
    }
}
