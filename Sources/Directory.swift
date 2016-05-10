import Darwin

public func currentDirectoryPath() throws -> String {
    let cwd = getcwd(nil, Int(PATH_MAX))
    guard cwd != nil else {
        // FIXME:
        free(cwd)
        throw Error.CannotGetCwd
    }
    guard let path = String(validatingUTF8: cwd!) else { throw Error.CannotGetCwd }
    return path
}

public func changeDirectory(path: String) throws {
    guard chdir(path) == 0 else {
        throw Error.CannotChangeDirectory
    }
}
