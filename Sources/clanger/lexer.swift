import Foundation

/** A Lexer allows one to iterate through `Token`s in an `InputStream`.
 */
public final class Lexer : IteratorProtocol {

    /** Create a Lexer for the given `InputStream`

        Parameter inputStream: a stream of C tokens, most commonly a C file.
    */
    public init(_ inputStream: InputStream) {
       self.inputStream = inputStream 
    }

    /// Advance to the next token in the `inputStream`, or nil.
    public func next() -> Token?  {
        return nil
    }

    // MARK: - Private
    private let inputStream: InputStream
}
