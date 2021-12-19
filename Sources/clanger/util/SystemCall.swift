import Foundation

/// Executes the command in the zsh shell, returning a status and any output.
@discardableResult
func systemCall(_ command: String) -> (status: Int32, output: String) {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    return (task.terminationStatus, output)
}