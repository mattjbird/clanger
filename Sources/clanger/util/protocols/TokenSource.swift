import Foundation

/// Represents an abstract token source, allowing us to decouple the Lexer from
/// the Parser and enabling us to implement various test helpers.
public protocol TokenSource {
  func next() -> CToken?
  func peek() -> CToken?

  var current: CToken? { get }
}

extension TokenSequence: TokenSource {}
