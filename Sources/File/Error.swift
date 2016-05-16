public enum FileError: ErrorProtocol {
    case CannotRemoveFile
}

extension FileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .CannotRemoveFile:
            return "Cannot remove file."
        }
    }
}
