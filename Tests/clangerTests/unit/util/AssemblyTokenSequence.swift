import Foundation
@testable import clanger

/// A lexer which exposes a sequence of `AssemblyTokens`s from a `CharacterStream`.
internal final class AssemblyTokenSequence: Sequence, IteratorProtocol {
  /// Create an AssemblyTokenSequence for the given `CharacterStream`.
  ///
  /// - Parameter characterStream: a stream of assembly tokens
  internal init(_ characterStream: CharacterStream) {
    self.characterStream = characterStream
  }

  /// Returns the next token in the `inputStream` or nil if we're at the end.
  internal func next() -> AssemblyToken? {
    var currentString = ""
    for c in self.characterStream {
      if c.isWhitespace {
        // Skip whitespace
        continue
      }

      // Check for single character tokens
      if currentString.isEmpty,
        let punctuation = AssemblyToken.AssemblyPunctuation(rawValue: c) {
        return self.updateCurrent(.punctuation(punctuation))
      }

      currentString.append(c)

      // Is this the end of our identifier?
      guard let next = self.characterStream.peek() else { break }
      if next.isWhitespace || AssemblyToken.AssemblyPunctuation(rawValue: next) != nil {
        break
      }
    }

    if currentString.isEmpty {
      return self.updateCurrent(nil)
    }

    return self.updateCurrent(AssemblyToken.fromString(currentString))
  }

  internal private(set) var current: AssemblyToken?

  // MARK: - Private
  private let characterStream: CharacterStream

  private func updateCurrent(_ token: AssemblyToken?) -> AssemblyToken? {
    self.current = token
    return token
  }
}
