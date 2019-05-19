//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

extension Process {
    enum ExecutionError: Error {
        case launchError(Error)
        case standardError(String)
    }

    /// Launches a process and waits for it to complete.
    ///
    /// - Parameters:
    ///   - executableUrl: The URL of the executable to launch.
    ///   - environment: A dictionary of environment variable values whose keys are the variable names.
    ///   - arguments: Sets the command arguments that should be used to launch the executable.
    static func launchAndWait(withExecutableUrl executableUrl: URL, environment: [String: String]? = nil, arguments: [String] = []) throws -> Data {
        let process = Process()
        process.launchPath = executableUrl.absoluteURL.path
        process.arguments = arguments

        if let environment = environment {
            process.environment = environment
        }

        let standardOutput = Pipe()
        process.standardOutput = standardOutput

        let standardError = Pipe()
        process.standardError = standardError

        process.launch()
        process.waitUntilExit()

        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
            let error = String(data: errorData, encoding: .utf8)!

            throw ExecutionError.standardError(error)
        }

        return standardOutput.fileHandleForReading.readDataToEndOfFile()
    }
}
