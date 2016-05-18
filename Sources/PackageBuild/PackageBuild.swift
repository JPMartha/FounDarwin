#if os(Linux)
import Glibc
#else
import Darwin
#endif
import func Directory.createDirectory
import enum Directory.DirectoryError

/**
 1. Create the `package` directory
 2. Copy the executable file
 */
public func preparePackage(targetDirectoryPath path: String, targetFileName name: String) throws {
    // TODO: clearly
    let packageDirectoryName = "package"
    do {
        try Directory.createDirectory(path: "\(path)/\(packageDirectoryName)")
    } catch {
        throw DirectoryError.CannotCreateDirectory
    }
    
    guard let fp = popen("cp -fv \(path)/\(name) \(path)/\(packageDirectoryName)", "w") else { return }
    pclose(fp)
    
    print("")
}

public func buildPackage(identifier: String, installLocation: String, root: String, name: String) {
    guard !identifier.isEmpty else { return }
    guard !installLocation.isEmpty else { return }
    guard !root.isEmpty else { return }
    guard !name.isEmpty else { return }
    
    //guard File.isAccessible(path: "") else {}
    
    // FIXME: current working directory
    guard let fp = popen("pkgbuild --identifier \"\(identifier)\" --install-location \"\(installLocation)\" --root \"\(root)\" \"\(name)\"", "r") else {
        return
    }
    let bufferSize = 4096
    var buffer = [Int8](repeating: 0, count: bufferSize)
    
    // FIXME: Hard-Coding
    fgets(&buffer, Int32(bufferSize), fp)
    write(STDOUT_FILENO, buffer, bufferSize)
    buffer = [Int8](repeating: 0, count: bufferSize)
    fgets(&buffer, Int32(bufferSize), fp)
    write(STDOUT_FILENO, buffer, bufferSize)
    
    pclose(fp)
    
    print("")
}

public func installPackage(name: String) {
    let fp = popen("sudo installer -pkg \(name) -target /", "r")
    pclose(fp)
}
