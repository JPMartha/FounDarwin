import Darwin

public func isAccessibleFile(path: String) -> Bool {
    guard !path.isEmpty else { return false}
    return access(path, F_OK) == 0
}

public func copyFile(path: String) {
    
}

public func removeFile(path: String) throws {
    guard rmdir(path) == 0 else {
        // TODO: Error Handling
        throw FileError.CannotRemoveFile
    }
}

public func renameFile(old: String, new: String) {
    rename(old, new)
}
