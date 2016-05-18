@testable import PackageBuild
import XCTest

final class PackageBuildTests: XCTestCase {
#if os(Linux)
#else
    private var workingDirectory = String()
    private let debugDirectory = ".build/debug"
    private let packageDirectoryName = "package"
    private let executableFileName = "testFounDarwin"
    private let packageFileName = "testFounDarwin.pkg"
    
    override func setUp() {
        super.setUp()
        
        let cwd = getcwd(nil, Int(PATH_MAX))
        guard let cd = cwd else {
            free(cwd)
            return
        }
        workingDirectory = String(validatingUTF8: cd)!
        if access("\(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)", F_OK) == 0 {
            rmdir("\(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)")
        }
        
        if access("\(workingDirectory)/\(packageFileName)", F_OK) == 0 {
            rmdir("\(workingDirectory)/\(packageFileName)")
        }
        
        guard let fp = fopen("\(workingDirectory)/\(debugDirectory)/\(executableFileName)", "w") else {
            XCTFail("\(workingDirectory)/\(debugDirectory)\(executableFileName)")
            return
        }
        fclose(fp)
    }
    
    override func tearDown() {
        rmdir("\(workingDirectory)\(debugDirectory)/\(packageDirectoryName)")
        rmdir("\(workingDirectory)/\(packageFileName)")
        super.tearDown()
    }
    
    func testPrepareAndBuildPackage() {
        do {
            try preparePackage(targetDirectoryPath: "\(workingDirectory)/\(debugDirectory)", targetFileName: executableFileName)
        } catch {
            XCTFail("preparePackage")
            return
        }
        
        XCTAssertEqual(
            access("\(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)", F_OK),
            0,
            "access \(debugDirectory)/\(packageDirectoryName)"
        )
        XCTAssertEqual(
            access("\(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)/\(executableFileName)", F_OK),
            0,
            "access \(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)/\(executableFileName)"
        )

        chdir(workingDirectory)
        buildPackage(identifier: "com.tryswiftconf.tryswiftdev", installLocation: "/usr/local/bin", root: "\(workingDirectory)/\(debugDirectory)/\(packageDirectoryName)", name: packageFileName)
        
        XCTAssertEqual(
            access("\(workingDirectory)/\(packageFileName)", F_OK),
            0,
            "access \(workingDirectory)/\(packageFileName)"
        )
    }
#endif
}
