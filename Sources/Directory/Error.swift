public enum DirectoryError: ErrorProtocol {
    case CannotGetCurrentDirectory
    case CannotChangeDirectory
    case CannotCreateDirectory
}

extension DirectoryError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .CannotGetCurrentDirectory:
            return "Cannot get the current directory path."
        case .CannotChangeDirectory:
            return "Cannot change directory."
        case .CannotCreateDirectory:
            return "Cannot create directory."
        }
    }
}
