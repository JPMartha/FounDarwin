#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

#if os(Linux)
    public func isAccessible(name: String) -> Bool {
        guard !name.isEmpty else { return false}
        return access(name, F_OK) == 0
    }
    
#else
    public func isAccessible(path: String) -> Bool {
        guard !path.isEmpty else { return false}
        return access(path, F_OK) == 0
    }
#endif

public func copy(path: String) {
    
}

public func remove(path: String) throws {
    guard rmdir(path) == 0 else {
        // TODO: Error Handling
        throw FileError.CannotRemoveFile
    }
}

public func rename(old: String, new: String) throws {
    guard rename(old, new) == 0 else {
        // TODO: Error Handling
        throw FileError.CannotRename
    }
}
