import Foundation

/// Takes a `TokenSource` and parses it into an abstract syntax tree.
public class Parser {
  /// Parses the tokens from a `TokenSource` into an AST of the C program.
  /// - Throws:
  ///   - `ParseError.unexpectedToken` if the tokens are syntactically invalid.
  ///   - `ParseError.overflow` if a data type would overflow
  public func parse(_ tokens: TokenSource) throws -> Program {
    let function = try self.parseFunction(tokens)
    return Program(function)
  }

  // MARK: - Internal
  internal func parseFunction(_ tokens: TokenSource) throws -> Function {
    if tokens.next() != .keyword(.int) {
      // TODO: we only handle programs consisting of a single main function
      throw ParseError.unexpectedToken
    }
    guard case .identifier(let name) = tokens.next() else {
      throw ParseError.unexpectedToken
    }
    if tokens.next() != .openParen {
      throw ParseError.unexpectedToken
    }
    if tokens.next() != .closeParen {
      throw ParseError.unexpectedToken
    }
    if tokens.next() != .openBrace {
      throw ParseError.unexpectedToken
    }
    let body = try self.parseStatement(tokens)
    if tokens.next() != .closeBrace {
      throw ParseError.unexpectedToken
    }
    return Function(name, body)
  }

  internal func parseStatement(_ tokens: TokenSource) throws -> Statement {
    switch tokens.next() {
      case .keyword(let keyword):
        switch keyword {
          case .return:
            let expression = try self.parseExpression(tokens)
            if tokens.next() != .semiColon {
              throw ParseError.unexpectedToken
            }
            return .return(expression)
          default:
            // TODO: we only handle returns
            throw ParseError.unexpectedToken
        }
      default:
        // TODO: we only handle returns
        throw ParseError.unexpectedToken
    }
  }

  internal func parseExpression(_ tokens: TokenSource) throws -> Expression {
    guard let token = tokens.next() else {
      // TODO: add an EOF token
      throw ParseError.unexpectedToken
    }
    if case .intLiteral(let str) = token {
      return .integerConstant( try self.parseIntegerLiteral(str) )
    } else if let op = self.parseOperator(token) {
      return .unaryOp(op, try self.parseExpression(tokens))
    }
    throw ParseError.unexpectedToken
  }

  // MARK: - Private

  /// - Throws: ParseError.overflow on an integer overflow
  private func parseIntegerLiteral(_ str: String) throws -> Int32 {
    // FIXME: cheat and use a large int type to parse the integer so we don't
    // have to worry about overflowing our own integers... This will need to
    // change if we decide to support 64-bit integers.
    let tokenValue: UInt64?
    if str.lowercased().hasPrefix("0x") {
      tokenValue = UInt64(
        str.suffix(from: str.index(str.startIndex, offsetBy: 2)),
        radix: 16
      )
    } else if str.hasPrefix("0") {
      tokenValue = UInt64(str, radix: 8)
    } else {
      tokenValue = UInt64(str)
    }
    guard let value = tokenValue, value <= Int32.max else {
      throw ParseError.overflow
    }
    return Int32(value)
  }

  private func parseOperator(_ token: CToken) -> Expression.Operator? {
    switch token {
      case .negation:           return .negation
      case .bitwiseComplement:  return .bitwiseComplement
      case .logicalNegation:    return .logicalNegation
      default:                  return nil
    }
  }
}
