import Foundation

// FIXME: move this to a different file.
/** Represents an abstract token source, allowing us to decouple the Lexer from
    the tokeniser
*/
public protocol TokenSource {
  func next() -> CToken?

  var current: CToken? { get }
  var line: Int { get }
  var column: Int { get }
}

extension TokenSequence: TokenSource {}

// FIXME: move this to the test stuff
public class TestTokenStream: TokenSource {
  public init(_ tokens: [CToken]) {
    self.tokens = tokens
  }

  public func next() -> CToken? {
    defer { self.currentTokenIdx += 1 }
    if self.currentTokenIdx >= self.tokens.count {
      return nil
    }
    return self.tokens[self.currentTokenIdx]
  }

  public var current: CToken? {
    return self.tokens[self.currentTokenIdx - 1]
  }

  public var line = 0, column = 0

  // MARK: - Private
  private let tokens: [CToken]
  private var currentTokenIdx = 0
}


/** Takes a `TokenSequence` and parses it into an abstract syntax tree */
public class Parser {
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
            return Return(expression)
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
        return IntegerConstant(value: UInt32(t)!)
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

public protocol Expression {

}

public struct IntegerConstant: Expression {
  let value: UInt32
}

public protocol Statement {

}

public struct Return: Statement {
  let expression: Expression

  public init(_ expression: Expression) {
    self.expression = expression
  }
}

public struct Function {
  let name: String
  let body: Statement

  public init(_ name: String, _ body: Statement) {
    self.name = name
    self.body = body
  }
}

public struct Program {
  let function: Function

  public init(_ function: Function) {
    self.function = function
  }
}
