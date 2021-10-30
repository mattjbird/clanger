import Foundation

/// Takes a `TokenSource` and parses it into an abstract syntax tree.
public class Parser {
  /// Parses the tokens from a `TokenSource` into an AST of the C program.
  /// - Throws: `ParseError.unexpectedToken` if the `TokenSource` is invalid.
  public func parse(_ tokens: TokenSource) throws -> Program {
    let function = try self.parseFunction(tokens)
    return Program(function)
  }

  // MARK: - Internal
  internal func parseFunction(_ tokens: TokenSource) throws -> Function {
    if tokens.next() != .keyword(.int) {
      // TODO: we only handle programs consisting of a single main function
      throw ParseError.unexpectedToken(tokens)
    }
    guard case .identifier(let name) = tokens.next() else {
      throw ParseError.unexpectedToken(tokens)
    }
    if tokens.next() != .openParen {
      throw ParseError.unexpectedToken(tokens)
    }
    if tokens.next() != .closeParen {
      throw ParseError.unexpectedToken(tokens)
    }
    if tokens.next() != .openBrace {
      throw ParseError.unexpectedToken(tokens)
    }
    let body = try self.parseStatement(tokens)
    if tokens.next() != .closeBrace {
      throw ParseError.unexpectedToken(tokens)
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
              throw ParseError.unexpectedToken(tokens)
            }
            return .return(expression)
          default:
            // TODO: we only handle returns
            throw ParseError.unexpectedToken(tokens)
        }
      default:
        // TODO: we only handle returns
        throw ParseError.unexpectedToken(tokens)
    }
  }

  internal func parseExpression(_ tokens: TokenSource) throws -> Expression {
    switch tokens.next() {
      case .intLiteral(let t):
        // FIXME: will need to handle overflow, hex, octal, etc.
        return .integerConstant(UInt32(t)!)
      default:
        // TODO: we only handle returns
        throw ParseError.unexpectedToken(tokens)
    }
  }
}
