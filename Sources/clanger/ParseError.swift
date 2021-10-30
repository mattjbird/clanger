import Foundation

/// An `Error` raised by the `Parser`.
/// Check the `TokenSource` for information on the line/column/token, etc.
public enum ParseError: Error {
  /// The `Parser` encountered an unexpected `CToken`
  case unexpectedToken
  /// The `Parser` encountered an integer overflow
  case overflow
}
