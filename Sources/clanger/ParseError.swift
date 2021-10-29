import Foundation

/// An `Error` raised by the `Parser`.
public enum ParseError: Error {
  /// The `Parser` was expecting one token and found another. The current
  /// parsing context can be retrieved from the `TokenSource`.
  case unexpectedToken(TokenSource)
}

// MARK: CustomStringConvertible
extension ParseError: CustomStringConvertible {
  /// A public-facing description of the error, suitable for exposing to the end-user.
  public var description: String {
    switch self {
      case .unexpectedToken(let tok):
        return "Unexpected token at \(tok.line):\(tok.column): '\(tok.current?.toString() ?? "nil"))'"
    }
  }
}