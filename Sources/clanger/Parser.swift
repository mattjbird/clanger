import Foundation

/** Takes a `TokenSequence` and parses it into an abstract syntax tree. */
public class Parser {
  /// Parses the tokens from a `TokenSource` into an AST of the C program.
  public func parse(_ tokens: TokenSource) -> Program {
    let function = self.parseFunction(tokens)
    return Program(function)
  }

  // MARK: - Private
  private func parseFunction(_ tokens: TokenSource) -> Function {
    if tokens.next() != .keyword(.int) {
      // TODO: we only handle programs consisting of a single main function
      ERR(tokens, "expected function declaration")
    }
    guard case .identifier(let name) = tokens.next() else {
      ERR(tokens, "expected function identifier")
    }
    if tokens.next() != .openParen {
      ERR(tokens, "expected parameter list")
    }
    if tokens.next() != .closeParen {
      ERR(tokens, "expected end of parameter list")
    }
    if tokens.next() != .openBrace {
      ERR(tokens, "expected start of function body")
    }
    let body = self.parseStatement(tokens)
    if tokens.next() != .closeBrace {
      ERR(tokens, "expected end of function body")
    }
    return Function(name, body)
  }

  private func parseStatement(_ tokens: TokenSource) -> Statement {
    switch tokens.next() {
      case .keyword(let keyword):
        switch keyword {
          case .return:
            let expression = self.parseExpression(tokens)
            if tokens.next() != .semiColon {
              ERR(tokens, "expected semicolon")
            }
            return .return(expression)
          default:
            // TODO: we only handle returns
            ERR(tokens, "expected return keyword")
        }
      default:
        // TODO: we only handle returns
        ERR(tokens, "expected return keyword")
    }
  }

  private func parseExpression(_ tokens: TokenSource) -> Expression {
    switch tokens.next() {
      case .intLiteral(let t):
        // FIXME: will need to handle overflow, hex, octal, etc.
        return .integerConstant(UInt32(t)!)
      default:
        // TODO: we only handle returns
        ERR(tokens, "expected integer constant")
    }
  }

  // FIXME: This needs to be thought through. Exiting the program when we hit
  // something unexpected *might* be okay at the top level, but isn't really
  // great for testing...?
  private func ERR(_ tokens: TokenSource, _ msg: String) -> Never {
    fatalError("parse error: [\(tokens.line):\(tokens.column)] \(msg) (got '\(tokens.current.toString())')")
  }
}

