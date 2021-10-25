import Foundation

/** Represents a buffered stream of `Character`s backed by an `InputStream`.

  Implemented as a wrapper on `InputStream`.
  The chief advantage here over a regular `InputStream` is that we can peek()
  and we get a little more Swift-friendly Characters rather than bytes.
 */
public final class CharacterStream: Sequence, IteratorProtocol {
  /**
    Parameter InputStream: an unopened `InputStream`. Normally a file but
    this Swift abstraction allows us to use `String`-backed `InputStream`s
    for ease of testing. The `InputStream` will be opened and closed by this
    class according to the RAII idiom.
  */
  public init(_ inputStream: InputStream) {
    self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.bufferCapacity)
    self.inputStream = inputStream
    self.inputStream.open()
  }

  deinit {
    self.inputStream.close()
  }

  /// Returns the next `Character` from the stream and advances the stream
  public func next() -> Character? {
    defer { self.bufferPtr += 1 }
    return self.nextCharacter()
  }

  /// Returns the next `Character` from the stream without advancing the stream
  public func peek() -> Character? {
    return self.nextCharacter()
  }

  // MARK: - Private
  private let bufferCapacity = 512

  private let inputStream: InputStream
  private let buffer: UnsafeMutablePointer<UInt8>

  private var bufferSize = 0
  private var bufferPtr = 0

  private func nextCharacter() -> Character? {
    if self.bufferPtr >= self.bufferSize {
      if !self.loadNewChunk() {
        return nil
      }
    }
    return Character(UnicodeScalar(self.buffer[self.bufferPtr]))
  }

  // Returns whether loading a new chunk succeeded
  private func loadNewChunk() -> Bool {
    guard self.inputStream.hasBytesAvailable else { return false }
    self.bufferSize = self.inputStream.read(
      self.buffer,
      maxLength: self.bufferCapacity
    )
    self.bufferPtr = 0
    return self.bufferSize > 0
  }
}
