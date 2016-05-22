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
                throw XCTFail("Cannot chdir")
            }
            XCTAssertEqual(access(testCreateDirectoryName, F_OK), 0)
        #else
            XCTAssertEqual(access("\(path)/\(testCreateDirectoryName)", F_OK), 0)
        #endif
        
        rmdir("\(path)/\(testCreateDirectoryName)")
    }
    
    func testIsAccessibleDirectory() {
        #if os(Linux)

            // TODO:

        #else
            guard let path = currentDirectoryForTest() else {
                XCTFail()
                return
            }
            print(path)
            
            let testAccessibleDirectory = "\(path)/testAccessibleDirectory"
            XCTAssertFalse(isAccessibleDirectory(path: testAccessibleDirectory))
            
            guard mkdir(testAccessibleDirectory, S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
                XCTFail("Cannot mkdir")
                return
            }
            XCTAssertTrue(isAccessibleDirectory(path: testAccessibleDirectory))
            
            rmdir(testAccessibleDirectory)
            XCTAssertFalse(isAccessibleDirectory(path: testAccessibleDirectory))
        #endif
    }
    
    func testRemoveDirectory() {
        #if os(Linux)

            // TODO:

        #else
            guard let path = currentDirectoryForTest() else {
                XCTFail()
                return
            }
            print(path)
            
            let testRemoveDirectory = "\(path)/testRemoveDirectory"
            guard mkdir(testRemoveDirectory, S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(access(testRemoveDirectory, F_OK), 0)
            
            removeDirectory(path: testRemoveDirectory)
            
            XCTAssertNotEqual(access(testRemoveDirectory, F_OK), 0)
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
