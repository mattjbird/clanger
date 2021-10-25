import Foundation

/** A Lexer allows one to iterate through `Token`s in an `InputStream`.
 */
public final class Lexer {
    /** Create a Lexer for the given `CharacterStream`

        Parameter characterStream: a stream of C tokens, most commonly a C file.
    */
    public init(_ characterStream: CharacterStream) {
       self.characterStream = characterStream
    }

    /// Returns the next token in the `inputStream` or nil if we're at the end.
    public func advance() -> CToken? {
        var current = ""
        for c in self.characterStream {
            // Skip whitespace
            if c.isWhitespace { continue }

            // Check for single character tokens
            if current.isEmpty, let token = CToken.punctuationMatch(c) {
                return token
            }

            current.append(c)

            // Is this the end of our identifier?
            guard let next = self.characterStream.peek() else { break }
            if next.isWhitespace || CToken.punctuationMatch(next) != nil {
                break
            }
        }

        if current.isEmpty {
            return nil
        }

        return CToken.fromString(current)
    }

    /// Returns a token iterator which allows things like `lexer.tokens.forEach({ ...`
    public var tokens: TokenSequence {
        return TokenSequence(lexer: self)
    }

    // MARK: - Private
    private let characterStream: CharacterStream
}


// MARK: TokenSequence
/// Helper class to make tokens from a `Lexer` iterable.
public final class TokenSequence: Sequence, IteratorProtocol {
    public init(lexer: Lexer) {
        self.lexer = lexer
    }

    /// Has the lexer iterate to the next token
    public func next() -> CToken? {
        return self.lexer.advance()
    }

    // MARK: Private
    private let lexer: Lexer
}
