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
  func parseFunction(_ tokens: TokenSource) throws -> Function {
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

  func parseStatement(_ tokens: TokenSource) throws -> Statement {
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

  func parseExpression(_ tokens: TokenSource) throws -> Expression {
    return try parseLogicalOrExpr(tokens)
  }

  // Multiple binary operations in the grammar take the form:
  //    <φ> ::= <ψ> { (o1 | o2 | o3 ...) <ψ> }
  // That is, the expression is composed of an arbitrary number of
  // sub-expressions chained together by a set of operators.
  // This higher-level parsing function abstracts that parsing pattern.
  func repeatingBinOpExpr(
    _ tokens: TokenSource,
    _ parser: (TokenSource) throws -> Expression,
    _ ops: [CToken]
  ) throws -> Expression {
    var expr = try parser(tokens)
    var next = tokens.peek()
    while next != nil, ops.contains(next!) {
      guard let op = parseBinaryOperator(tokens.next()!) else {
        throw ParseError.unexpectedToken
      }
      let expr2 = try parser(tokens)
      expr = .binaryOp(op, expr, expr2)
      next = tokens.peek()
    }
    return expr
  }

  // <expr> ::= <logical-and-expr> { "||" <logical-and-expr> }
  func parseLogicalOrExpr(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(tokens, parseLogicalAndExpr, [.or])
  }

  // <logical-and-expr> ::= <equality-expr> { "&&" <equality-expr> }
  func parseLogicalAndExpr(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(tokens, parseEqualityExpr, [.and])
  }

  // <equality-expr> ::= <relational-expr> { ("!=" | "==") <relational-expr> }
  func parseEqualityExpr(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(tokens, parseRelationalExpr, [.equal, .notEqual])
  }

  // <relational-expr> ::= <additive-expr> { ("<" | ">" | "<=" | ">=") <additive-expr> }
  func parseRelationalExpr(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(
      tokens,
      parseAdditiveExpr,
      [.lessThan, .greaterThan, .lessThanOrEqual, .greaterThanOrEqual]
    )
  }

  // <additive-expr> ::= <term> { ("+" | "-") <term> }
  func parseAdditiveExpr(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(tokens, parseTerm, [.addition, .hyphen])
  }

  // <term> ::= <factor> { ("*" | "/") <factor> }
  func parseTerm(_ tokens: TokenSource) throws -> Expression {
    return try repeatingBinOpExpr(tokens, parseFactor, [.asterisk, .division])
  }

  // <factor> ::= "(" <exp> ")" | <unary_op> <factor> | <int>
  func parseFactor(_ tokens: TokenSource) throws -> Expression {
    guard let token = tokens.next() else {
      // TODO: add an EOF token
      throw ParseError.unexpectedToken
    }
    if token == .openParen {
      // <factor> ::= "(" <exp> ")"
      let expr = try parseExpression(tokens)
      if tokens.next() != .closeParen {
        throw ParseError.unexpectedToken
      }
      return expr
    } else if let op = parseUnaryOperator(token) {
      // <factor> ::= <unary_op> <factor>
      let factor = try parseFactor(tokens)
      return .unaryOp(op, factor)
    } else if case .intLiteral(let str) = token {
      // <factor> ::= <int>
      return .integerConstant( try self.parseIntegerLiteral(str) )
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

  private func parseUnaryOperator(_ token: CToken) -> Expression.UnaryOperator? {
    switch token {
      case .hyphen:             return .negation
      case .bitwiseComplement:  return .bitwiseComplement
      case .logicalNegation:    return .logicalNegation
      default:                  return nil
    }
  }

  private func parseBinaryOperator(_ token: CToken) -> Expression.BinaryOperator? {
    switch token {
      case .hyphen:             return .minus
      case .addition:           return .add
      case .asterisk:           return .multiply
      case .division:           return .divide
      case .equal:              return .equal
      case .notEqual:           return .notEqual
      case .and:                return .and
      case .or:                 return .or
      case .lessThan:           return .lessThan
      case .greaterThan:        return .greaterThan
      case .lessThanOrEqual:    return .lessThanOrEqual
      case .greaterThanOrEqual: return .greaterThanOrEqual
      default:                  return nil
    }
  }
}
