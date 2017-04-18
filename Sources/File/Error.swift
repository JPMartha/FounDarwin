public enum FileError: ErrorProtocol {
    case CannotRemoveFile
    case CannotRename
}

extension FileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .CannotRemoveFile:
            return "Cannot remove file."
        case .CannotRename:
            return "Cannot rename file."
        }
    }
}
