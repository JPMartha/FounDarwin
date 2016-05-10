import Darwin

private var cd = String()

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

public func downloadPackage(snapshotVersion: String) {
    
    // A Work In Progress
    
    let fp = popen("curl -O https://swift.org/builds/development/xcode/\(snapshotVersion)/\(snapshotVersion)-osx.pkg", "r")
    print("")
    print("Downloading...")
    print("")
    
    pclose(fp)
    
    print("")
}

public func installPackage(snapshotVersion: String) {
    
    // A Work In Progress
    do {
        cd = try currentDirectoryPath()
    } catch {
        // TODO: Error Handling
        print(Error.CannotGetCwd)
        return
    }
    
    guard !cd.isEmpty else {
        // TODO: Error Handling
        print(Error.CannotGetCwd)
        return
    }
    
    let fp = popen("sudo installer -pkg \(cd)/\(snapshotVersion)-osx.pkg -target /", "r")
    print("")
    print("Installing...")
    print("")
    
    // TODO:
    let bufferSize = 4096
    var buffer = [Int8](repeating: 0, count: bufferSize + 1)
    
    // FIXME: Hard-Coding
    fgets(&buffer, Int32(bufferSize), fp)
    write(STDOUT_FILENO, buffer, bufferSize)
    buffer = [Int8](repeating: 0, count: bufferSize + 1)
    fgets(&buffer, Int32(bufferSize), fp)
    write(STDOUT_FILENO, buffer, bufferSize)
    buffer = [Int8](repeating: 0, count: bufferSize + 1)
    fgets(&buffer, Int32(bufferSize), fp)
    write(STDOUT_FILENO, buffer, bufferSize)
    buffer = [Int8](repeating: 0, count: bufferSize + 1)
    
    pclose(fp)
    
    print("")
}

public func removePkgFile(snapshotVersion: String) {
    // A Work In Progress
    
    let fp = popen("rm \(cd)/\(snapshotVersion)-osx.pkg", "r")
    pclose(fp)
    
    print("")
    print("Removing...")
    print("")
}
