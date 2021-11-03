import Foundation

/// A wrapper on `OutputStream` which conforms to `OutputHandler`.
public final class FileOutputHandler: OutputHandler {
  /// Returns a `FileOutputHandler` if the file `path` exists, else nil.
  /// - Parameter path: a relative (or absolute) path to a file.
  public init?(_ path: String) {
    guard !FileManager.default.fileExists(atPath: path) else {
      logger.error("File already exists at \(path)")
      return nil
    }
    guard let out = OutputStream(toFileAtPath: path, append: true) else {
      return nil
    }
    out.open()
    self.outputStream = out
    self.outputStream.open()
  }

  deinit {
    self.outputStream.close()
  }

  // MARK: OutputHandler
  public func emit(_ str: String) {
    self.outputStream.write(Array(str.utf8), maxLength: str.utf8.count)
  }

  // MARK: - Private
  private let outputStream: OutputStream;
}