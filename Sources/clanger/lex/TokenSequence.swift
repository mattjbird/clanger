import Foundation

/// A lexer which exposes a sequence of `CToken`s from a `CharacterStream`.
public final class TokenSequence: Sequence, IteratorProtocol {
  /// Create a TokenSequence for the given `CharacterStream`.
  ///
  /// - Parameter characterStream: a stream of C tokens, most commonly a C file.
  public init(_ characterStream: CharacterStream) {
    self.characterStream = characterStream
  }

  /// Returns the next token in the `inputStream` or nil if we're at the end.
  /// Advances the token stream to the next token.
  public func next() -> CToken? {
    if let next = peeked {
      (current, line, column) = next
      peeked = nil
    } else {
      (current, line, column) = _next(line, column)
    }
    return current
  }

  /// Returns the next token in the `inputStream` or nil if we're at the end.
  /// Does not advance the token stream.
  public func peek() -> CToken? {
    peeked = peeked ?? _next(line, column)
    return peeked?.token
  }

  public private(set) var current: CToken?

  /// A string with the context (current token; line; column) for debugging.
  public var debugContext: String {
    return "'\(current?.debugDescription ?? "")' (line:\(line) col:\(column))"
  }

  // MARK: - Internal
  internal private(set) var line: Int = 1
  internal private(set) var column: Int = -1

  // MARK: - Private
  private let characterStream: CharacterStream

  private var peeked: (token: CToken?, line: Int, col: Int)?

  /// Returns the next token in the stream, including any line and column changes.
  private func _next(_ line: Int, _ col: Int) -> (CToken?, line: Int, col: Int) {
    var line = line; var col = col
    var currentString = ""
    for c in characterStream {
      col += 1

      if c.isWhitespace {
        if c.isNewline {
          line += 1
          col = -1
        }
        // Skip whitespace
        continue
      }

      // Check for single character tokens
      if currentString.isEmpty, let token = CToken.punctuationMatch(c) {
        return (token, line, col)
      }

      currentString.append(c)

      // Is this the end of our identifier?
      guard let next = characterStream.peek() else { break }
      if next.isWhitespace || CToken.punctuationMatch(next) != nil {
        break
      }
    }

    if currentString.isEmpty {
      return (nil, line, col)
    }

    return (CToken.fromString(currentString), line, col)
  }
}
