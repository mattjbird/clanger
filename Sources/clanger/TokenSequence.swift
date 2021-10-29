import Foundation

/** A lexer which exposes a sequence of `CToken`s from a `CharacterStream`.
 */
public final class TokenSequence: Sequence, IteratorProtocol {
  /** Create a TokenSequence for the given `CharacterStream`.

    Parameter characterStream: a stream of C tokens, most commonly a C file.
  */
  public init(_ characterStream: CharacterStream) {
    self.characterStream = characterStream
  }

  /// Returns the next token in the `inputStream` or nil if we're at the end.
  public func next() -> CToken? {
    var currentString = ""
    for c in self.characterStream {
      self.column += 1

      if c.isWhitespace {
        if c.isNewline {
          self.line += 1
          self.column = -1
        }
        // Skip whitespace
        continue
      }

      // Check for single character tokens
      if currentString.isEmpty, let token = CToken.punctuationMatch(c) {
        return self.updateCurrent(token)
      }

      currentString.append(c)

      // Is this the end of our identifier?
      guard let next = self.characterStream.peek() else { break }
      if next.isWhitespace || CToken.punctuationMatch(next) != nil {
        break
      }
    }

    if currentString.isEmpty {
      return self.updateCurrent(nil)
    }

    return self.updateCurrent(CToken.fromString(currentString))
  }

  public private(set) var current: CToken?

  public private(set) var line: Int = 0
  public private(set) var column: Int = -1

  // MARK: - Private
  private let characterStream: CharacterStream

  private func updateCurrent(_ token: CToken?) -> CToken? {
    self.current = token
    return token
  }
}
