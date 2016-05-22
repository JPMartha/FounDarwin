#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
 - seealso: https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/getcwd.3.html
 */
public func currentDirectoryPath() throws -> String {
    #if os(Linux)
        let cwd = getcwd(nil, 0)
        guard let cd = cwd else {
            free(cwd)
            throw DirectoryError.CannotGetCurrentDirectory
        }
    #else
        let cwd = getcwd(nil, Int(PATH_MAX))
        guard let cd = cwd else {
            // If buf is NULL, space is allocated as necessary to store the pathname.
            // This space may later be free(3)'d.
            free(cwd)
            throw DirectoryError.CannotGetCurrentDirectory
        }
    #endif
    guard let path = String(validatingUTF8: cd) else {
        throw DirectoryError.CannotGetCurrentDirectory
    }
    return path
}

public func changeDirectory(path: String) throws {
    guard chdir(path) == 0 else {
        throw DirectoryError.CannotChangeDirectory
    }
}

public func createDirectory(path: String) throws {
    // TODO: Consider about the modes
    guard mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO) == 0 || errno == EEXIST else {
        throw DirectoryError.CannotCreateDirectory
    }
}

#if os(Linux)
    public func isAccessibleDirectory(name: String) -> Bool {
        // TODO: Error Handling
        guard !name.isEmpty else { return false}
        return access(name, F_OK) == 0
    }
#else
    public func isAccessibleDirectory(path: String) -> Bool {
        // TODO: Error Handling
        guard !path.isEmpty else { return false}
        return access(path, F_OK) == 0
    }
#endif

public func removeDirectory(path: String) {
    rmdir(path)
}
