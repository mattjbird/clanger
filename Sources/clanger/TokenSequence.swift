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
      // Skip whitespace
      if c.isWhitespace { continue }

      // Check for single character tokens
      if currentString.isEmpty, let token = CToken.punctuationMatch(c) {
        return token
      }

      currentString.append(c)

      // Is this the end of our identifier?
      guard let next = self.characterStream.peek() else { break }
      if next.isWhitespace || CToken.punctuationMatch(next) != nil {
        break
      }
    }

    if currentString.isEmpty {
      return nil
    }

    return CToken.fromString(currentString)
  }

  // MARK: - Private
  private let characterStream: CharacterStream
}
