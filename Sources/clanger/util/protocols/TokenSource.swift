import Foundation

/// Represents an abstract token source, allowing us to decouple the Lexer from
/// the Parser and enabling us to implement various test helpers.
public protocol TokenSource {
  func next() -> CToken?

  var current: CToken? { get }
  var line: Int { get }
  var column: Int { get }
}

extension TokenSequence: TokenSource {}
