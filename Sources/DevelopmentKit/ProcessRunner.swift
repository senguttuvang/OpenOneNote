import Foundation
import Darwin

public struct ProcessResult: Sendable {
    public let exitCode: Int32
    public let stdout: String
}

public enum DevelopmentError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case commandFailed(String, Int32)
    case timedOut(String)
    case outputExists(String)
    case uncommittedSource

    public var description: String {
        switch self {
        case .invalidArguments(let detail): detail
        case .commandFailed(let tool, let code): "\(tool) exited with status \(code)"
        case .timedOut(let tool): "\(tool) exceeded its deadline and was terminated"
        case .outputExists(let path): "Evidence output already exists: \(path)"
        case .uncommittedSource: "Commit Package.swift and Sources before archiving a reproducible build"
        }
    }
}

/// Typed process boundary following the existing Maintenance ProcessClient convention.
/// Arguments are passed directly to exec; no command strings or shell interpolation.
public protocol ProcessRunning {
    func run(_ tool: String, _ arguments: [String], at directory: URL,
             capture: Bool, timeout: TimeInterval, allowFailure: Bool, environment: [String: String]) throws -> ProcessResult
}

public struct NativeProcessRunner: ProcessRunning {
    public init() {}
    public func run(_ tool: String, _ arguments: [String], at directory: URL,
                    capture: Bool = false, timeout: TimeInterval = 1200,
                    allowFailure: Bool = false, environment: [String: String] = [:]) throws -> ProcessResult {
        guard timeout > 0, timeout.isFinite else { throw DevelopmentError.invalidArguments("Timeout must be positive and finite") }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [tool] + arguments
        process.currentDirectoryURL = directory
        process.environment = ProcessInfo.processInfo.environment.merging(environment) { _, replacement in replacement }
        let output = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNote-command-\(UUID()).txt")
        var handle: FileHandle?
        if capture {
            guard FileManager.default.createFile(atPath: output.path, contents: nil) else { throw CocoaError(.fileWriteUnknown) }
            handle = try FileHandle(forWritingTo: output)
            process.standardOutput = handle
        } else { process.standardOutput = FileHandle.standardOutput }
        process.standardError = FileHandle.standardError
        defer {
            try? handle?.close()
            if capture { try? FileManager.default.removeItem(at: output) }
        }
        try process.run()
        let deadline = ProcessInfo.processInfo.systemUptime + timeout
        while process.isRunning && ProcessInfo.processInfo.systemUptime < deadline { Thread.sleep(forTimeInterval: 0.025) }
        if process.isRunning {
            process.terminate()
            let grace = ProcessInfo.processInfo.systemUptime + 2
            while process.isRunning && ProcessInfo.processInfo.systemUptime < grace { Thread.sleep(forTimeInterval: 0.025) }
            if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            process.waitUntilExit()
            throw DevelopmentError.timedOut(tool)
        }
        process.waitUntilExit()
        try handle?.synchronize()
        let stdout = capture ? try String(contentsOf: output, encoding: .utf8) : ""
        guard allowFailure || process.terminationStatus == 0 else { throw DevelopmentError.commandFailed(tool, process.terminationStatus) }
        return ProcessResult(exitCode: process.terminationStatus, stdout: stdout.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
