import Foundation
import os.log

enum LogCategory: String {
    case app
    case auth
    case games
    case images
    case factory
}

private struct Loggers {
    static var cache: [LogCategory: Logger] = [:]

    static func logger(for category: LogCategory) -> Logger {
        if let logger = cache[category] { return logger }
        let subsystem = Bundle.main.bundleIdentifier ?? "GamesappCollectionManager"
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        cache[category] = logger
        return logger
    }
}

func log(_ message: String, category: LogCategory = .app, level: OSLogType = .debug) {
    #if DEBUG
    Loggers.logger(for: category).log(level: level, "\(message, privacy: .public)")
    #else
    guard level != .debug else { return }
    Loggers.logger(for: category).log(level: level, "\(message, privacy: .public)")
    #endif
}
