import Foundation

/** A Lexer allows one to iterate through `Token`s in an `InputStream`.
 */
public final class Lexer {
    /** Create a Lexer for the given `InputStream`

        Parameter inputStream: a stream of C tokens, most commonly a C file.
    */
    public init(_ inputStream: InputStream) {
       self.inputStream = inputStream
       self.currentToken = nil
    }

    /*
        int main() {
            return 2;
        }

        int main(){return 2;}
    */

    /// Returns the next token in the `inputStream` or nil if we're at the end.
    public func advance() -> CToken? {
        guard self.inputStream.hasBytesAvailable else {
            return nil
        }
        return self.currentToken
    }

    public var currentToken: CToken?

    /// Returns a token iterator which allows things like `lexer.tokens.forEach({ ...`
    public var tokens: TokenSequence {
        return TokenSequence(lexer: self)
    }

    // MARK: - Private
    private let inputStream: InputStream
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
