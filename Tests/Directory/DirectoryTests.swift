@testable import Directory
import XCTest

final class DirectoryTests: XCTestCase {
    func testCurrentDirectory() {
        #if os(Linux)
        #else
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
        print(path)
        #endif
    }
    
    func currentDirectoryWithDarwin() -> String? {
        #if os(Linux)
        #else
            let cwd = getcwd(nil, Int(PATH_MAX))
            guard let cd = cwd else {
                free(cwd)
                XCTFail()
                return nil
            }
            guard let path = String(validatingUTF8: cd) else {
                XCTFail()
                return nil
        }
        
        return path
        #endif
    }
    
    func testChangeDirectory() {
        #if os(Linux)
        #else
            guard let path1 = currentDirectoryWithDarwin() else {
                XCTFail()
                return
            }
        print(path1)
        
        do {
            try changeDirectory(path: "\(path1)/.build")
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
        
        // TODO: Verify
        
        guard let path2 = currentDirectoryWithDarwin() else {
            XCTFail()
            return
        }
        print(path2)
        
        // It is necessary for making a success of the other tests
        //   to change working directory into path1.
        
        do {
            try changeDirectory(path: path1)
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotChangeDirectory)
            return
        }
        #endif
    }
    
    func testCreateDirectory() {
        #if os(Linux)
        #else
        guard let path = currentDirectoryWithDarwin() else {
            XCTFail()
            return
        }
        print(path)
        
        do {
            try createDirectory(path: "\(path)/testCreateDirectory")
        } catch {
            XCTAssertThrowsError(DirectoryError.CannotCreateDirectory)
            return
        }
        
        XCTAssertEqual(access("\(path)/testCreateDirectory", F_OK), 0)
        
        rmdir("\(path)/testCreateDirectory")
        #endif
    }
    
    func testIsAccessibleDirectory() {
        #if os(Linux)
        #else
            guard let path = currentDirectoryWithDarwin() else {
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
        #else
        guard let path = currentDirectoryWithDarwin() else {
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
        /*
        var currentDirectory = String()
        let testDirectoryName = "testChangeDirectory"
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
        
        #if os(Linux)
            print("CurrentDirectoryPath: \(currentDirectory)")
        #else
            print("CurrentDirectoryPath: \(currentDirectory)")
            let fp = popen("echo $PWD", "r")
            
            // FIXME: Hard-Coding
            let bufferSize = 4096
            var buffer = [Int8](repeating: 0, count: bufferSize + 1)
            fgets(&buffer, Int32(bufferSize), fp)
            guard let cd = String(validatingUTF8: buffer) else {
                XCTFail("Cannot validatingUTF8")
                return
            }
            pclose(fp)
            
            XCTAssertEqual(String(cd.characters.dropLast()), currentDirectory)
        #endif
        
        do {
            try createDirectory(path: "\(currentDirectory)/\(testDirectoryName)")
        } catch {
            XCTFail()
            return
        }
        #if os(Linux)
            // TODO:
        #else
            XCTAssertTrue(access("\(currentDirectory)/\(testDirectoryName)", F_OK) == 0)
        #endif
        
        do {
            try changeDirectory(path: "\(currentDirectory)/\(testDirectoryName)")
        } catch {
            XCTFail("Cannot changeDirectory")
            return
        }
        rmdir("\(currentDirectory)/\(testDirectoryName)")
 */
    //}
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
