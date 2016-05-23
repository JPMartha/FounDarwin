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
        print("CurrentDirectoryPath: \(path)")
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
    
    func testChange() {
        guard let path1 = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print("CurrentDirectoryPath: \(path1)")
        
        do {
            try change(path: "\(path1)/.build")
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
        
        // TODO: Verify
        
        guard let path2 = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print("CurrentDirectoryPath: \(path2)")
        
        // It is necessary for making a success of the other tests
        //   to change working directory into path1.
        
        do {
            try change(path: path1)
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
    }
    
    func testCreate() {
        guard let path = currentDirectoryForTest() else {
            XCTFail("Failed: currentDirectoryForTest")
            return
        }
        print("CurrentDirectoryPath: \(path)")
        
        let testCreateDirectoryName = "testCreateDirectory"
        do {
            try create(path: "\(path)/\(testCreateDirectoryName)")
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
            print("Access: \(testCreateDirectoryName)")
        #else
            XCTAssertEqual(access("\(path)/\(testCreateDirectoryName)", F_OK), 0)
            print("Access: \(path)/\(testCreateDirectoryName)")
        #endif
        
        rmdir("\(path)/\(testCreateDirectoryName)")
    }
    
    func testIsAccessible() {
        guard let path = currentDirectoryForTest() else {
            XCTFail("Failed: currentDirectoryForTest")
            return
        }
        print("CurrentDirectoryPath: \(path)")
        
        let testAccessibleDirectoryName = "testAccessibleDirectory"
        #if os(Linux)
            XCTAssertFalse(isAccessible(name: testAccessibleDirectoryName))
            print("Cannot access: \(testAccessibleDirectoryName)")
        #else
            XCTAssertFalse(isAccessible(path: "\(path)/\(testAccessibleDirectoryName)"))
            print("Cannot access \(path)/\(testAccessibleDirectoryName)")
        #endif
        
        guard mkdir("\(path)/\(testAccessibleDirectoryName)", S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
            XCTFail("Cannot mkdir")
            return
        }
        
        #if os(Linux)
            XCTAssertTrue(isAccessible(name: testAccessibleDirectoryName))
            print("Access \(testAccessibleDirectoryName)")
        #else
            XCTAssertTrue(isAccessible(path: "\(path)/\(testAccessibleDirectoryName)"))
            print("Access \(path)/\(testAccessibleDirectoryName)")
        #endif
        
        rmdir("\(path)/\(testAccessibleDirectoryName)")
        #if os(Linux)
            XCTAssertFalse(isAccessible(name: testAccessibleDirectoryName))
            print("Cannot access: \(testAccessibleDirectoryName)")
        #else
            XCTAssertFalse(isAccessible(path: "\(path)/\(testAccessibleDirectoryName)"))
            print("Cannot access \(path)/\(testAccessibleDirectoryName)")
        #endif
    }
    
    func testRemove() {
        guard let path = currentDirectoryForTest() else {
            XCTFail()
            return
        }
        print("CurrentDirectoryPath: \(path)")
        
        let testRemoveDirectoryName = "testRemoveDirectory"
        guard mkdir("\(path)/\(testRemoveDirectoryName)", S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
            XCTFail()
            return
        }
        
        #if os(Linux)
            XCTAssertEqual(access(testRemoveDirectoryName, F_OK), 0)
            print("Access \(testRemoveDirectoryName)")
        #else
            XCTAssertEqual(access("\(path)/\(testRemoveDirectoryName)", F_OK), 0)
        #endif
        
        Directory.remove(path: "\(path)/\(testRemoveDirectoryName)")
        
        #if os(Linux)
            XCTAssertNotEqual(access(testRemoveDirectoryName, F_OK), 0)
            print("Cannot access \(testRemoveDirectoryName)")
        #else
            XCTAssertNotEqual(access("\(path)/\(testRemoveDirectoryName)", F_OK), 0)
            print("Cannot access \(path)/\(testRemoveDirectoryName)")
        #endif
    }
}

extension DirectoryTests {
    static var allTests : [(String, (DirectoryTests) -> () throws -> Void)] {
        return [
                   ("testCurrentDirectory", testCurrentDirectory),
                   ("testChange", testChange),
                   ("testCreate", testCreate),
                   ("testIsAccessible", testIsAccessible),
                   ("testRemove", testRemove),
        ]
    }
}
