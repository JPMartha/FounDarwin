#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
import func Directory.currentDirectoryPath
import enum Directory.DirectoryError

private var cd = String()

#if os(Linux)
#else
public func executeCommand(argments args: [String]) -> String? {
    var pipe: [Int32] = [0, 0]
    Darwin.pipe(&pipe)
    
    var fileActions: posix_spawn_file_actions_t? = nil
    posix_spawn_file_actions_init(&fileActions)
    
    posix_spawn_file_actions_addopen(&fileActions, 0, "/dev/null", O_RDONLY, 0)
    posix_spawn_file_actions_adddup2(&fileActions, pipe[1], 1)
    
    posix_spawn_file_actions_addclose(&fileActions, pipe[0])
    posix_spawn_file_actions_addclose(&fileActions, pipe[1])
    
    let argv: [UnsafeMutablePointer<CChar>?] = args.map{ $0.withCString(strdup) }
    var pid = pid_t()
    posix_spawnp(&pid, argv[0], &fileActions, nil, argv + [nil], nil)
    posix_spawn_file_actions_destroy(&fileActions)
    
    close(pipe[1])
    
    let bufferSize = 8192
    var buffer = [Int8](repeating: 0, count: bufferSize + 1)
    
    var n: Int
    var outputString = String()
    
    repeat {
        n = read(pipe[0], &buffer, bufferSize)
        if let output = String(validatingUTF8: buffer) {
            outputString.append(output)
        }
        buffer = [Int8](repeating: 0, count: bufferSize + 1)
    } while n > 0
    
    // TODO: wait
    // TODO: error
    
    close(pipe[0])
    
    return outputString.isEmpty ? nil : outputString
}
#endif

public func downloadDevelopmentSnapshot(version: String) {
    
    // A Work In Progress
    
    let fp = popen("curl -O https://swift.org/builds/development/xcode/\(version)/\(version)-osx.pkg", "r")
    print("")
    print("Downloading...")
    print("")
    
    pclose(fp)
    
    print("")
}

public func installDevelopmentSnapshot(version: String) throws {
    
    // A Work In Progress
    do {
        cd = try currentDirectoryPath()
    } catch {
        // TODO: Error Handling
        throw DirectoryError.CannotGetCurrentDirectory
    }
    
    guard !cd.isEmpty else {
        // TODO: Error Handling
        throw DirectoryError.CannotGetCurrentDirectory
    }
    
    let fp = popen("sudo installer -pkg \(cd)/\(version)-osx.pkg -target /", "w")
    print("")
    print("Installing...")
    print("")
    
    pclose(fp)
    
    print("")
}

public func removePkgFile(snapshotVersion: String) {
    
    // A Work In Progress
    
    guard cd.isEmpty else { return }
    
    let fp = popen("rm \(cd)/\(snapshotVersion)-osx.pkg", "r")
    pclose(fp)
    
    print("")
    print("Removing...")
    print("")
}
