enum Error: ErrorProtocol {
    case CannotGetCwd
    case CannotChangeDirectory
}

extension Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .CannotGetCwd:
            return "Cannot get the current directory path."
        case .CannotChangeDirectory:
            return "Cannot change directory."
        }
    }
}
