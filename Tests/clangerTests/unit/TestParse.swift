import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the output of the Lex step and the Parser.
/// Takes C tokens and checks that the correct abstract-syntax tree is created.
class TestParser: XCTestCase {
  private let parser = Parser()
}

// MARK: Expressions
extension TestParser {
  func testIntegerConstantExpressions() {
    for i in stride(from: 0, to: 32, by: 1) {
      let n = Int32(UInt64((1 << i) - 1))
      let decimal = String(n)
      let hexadecimal = "0x" + String(n, radix: 16)
      let octal = "0" + String(n, radix: 8)
      for representation in [decimal, hexadecimal, octal] {
        self.testExpression([.intLiteral( representation )], .integerConstant(n))
      }
    }
  }

  func testIntegerConstantExpressionOverflow() {
    let tooBig = UInt64(Int32.max) + 1
    let decimal = String(tooBig)
    let hexadecimal = "0x" + String(tooBig, radix: 16)
    let octal = "0" + String(tooBig, radix: 8)
    for representation in [decimal, hexadecimal, octal] {
      self.testExpression([ .intLiteral(representation)], throwsError: .overflow)
    }
  }

  private func tokenUnaryOpPairs() -> [(CToken, Expression.UnaryOperator)] {
    return [
      // token     =>       operator
      (.hyphen,            .negation),
      (.bitwiseComplement, .bitwiseComplement),
      (.logicalNegation,   .logicalNegation),
    ]
  }

  func testUnaryOperatorExpressionsBasic() {
    for (tokOp, op) in tokenUnaryOpPairs() {
      self.testExpression(
        [tokOp, .intLiteral("1337")],
        .unaryOp(op, .integerConstant(1337))
      )
    }
  }

  func testUnaryOperatorExpressionsNested() {
    self.testExpression(
      [.hyphen, .hyphen, .intLiteral("0")],
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(0)))
    )
    self.testExpression(
      [.bitwiseComplement, .hyphen, .logicalNegation, .intLiteral("9001")],
      .unaryOp(
        .bitwiseComplement,
        .unaryOp(
          .negation,
          .unaryOp(
            .logicalNegation,
            .integerConstant(9001)
          )
        )
      )
    )
  }

  func testUnaryOperatorExpressionsMissingOperands() {
    for tokOp in tokenUnaryOpPairs().map(\.0) {
      self.testExpression([tokOp], throwsError: .unexpectedToken)
      self.testExpression([tokOp, tokOp], throwsError: .unexpectedToken)
    }
  }

  private func tokenBinaryOpPairs() -> [(CToken, Expression.BinaryOperator)] {
    return [
      // token => operator
      (.addition, .add),
      (.hyphen,   .minus),
      (.asterisk, .multiply),
      (.division, .divide),
    ]
  }

  func testBinaryOperatorExpressionsBasic() {
    // e.g., 1 + 2
    for (tokOp, op) in tokenBinaryOpPairs() {
      self.testExpression(
        [.intLiteral("1"), tokOp, .intLiteral("2")],
        .binaryOp(op, .integerConstant(1), .integerConstant(2))
      )
    }
  }

  func testBinaryOperatorExpressionsLeftAssociativity() {
    // e.g., 1 + 2 + 3
    for (tokOp, op) in tokenBinaryOpPairs() {
      self.testExpression(
        [.intLiteral("1"), tokOp, .intLiteral("2"), tokOp, .intLiteral("3")],
        .binaryOp(
          op,
          .binaryOp(
            op,
            .integerConstant(1),
            .integerConstant(2)
          ),
          .integerConstant(3)
        )
      )
    }
  }

  func testBinaryOperatorExpressionsNested() {
    // braces e.g., 1 + ((2 + 3) + 4)
    for (tokOp, op) in tokenBinaryOpPairs() {
      self.testExpression([
        .intLiteral("1"),
        tokOp,
        .openParen,
        .openParen,
        .intLiteral("2"),
        tokOp,
        .intLiteral("3"),
        .closeParen,
        tokOp,
        .intLiteral("4"),
        .closeParen
      ],
        .binaryOp(
          op,
          .integerConstant(1),
          .binaryOp(
            op,
            .binaryOp(
              op,
              .integerConstant(2),
              .integerConstant(3)
            ),
            .integerConstant(4)
          )
        )
      )
    }
  }
}

// MARK: Statements
extension TestParser {
  func testReturnStatements() {
    self.testStatement(
      [.keyword(.return), .intLiteral("0"), .semiColon],
      Statement.return( Expression.integerConstant(0) )
    )
  }
}

// MARK: Functions
extension TestParser {
  func testBasicFunction() {
    self.testFunction(
      [
        .keyword(.int),
        .identifier("main"),
        .openParen,
        .closeParen,
        .openBrace,
        .keyword(.return),
        .intLiteral("0"),
        .semiColon,
        .closeBrace
      ],
      Function(
        "main",
        Statement.return(
          Expression.integerConstant(0)
        )
      )
    )
  }
}

// MARK: Programs
extension TestParser {
  func testBasicProgram() {
    self.testProgram(
      [
        .keyword(.int),
        .identifier("main"),
        .openParen,
        .closeParen,
        .openBrace,
        .keyword(.return),
        .intLiteral("0"),
        .semiColon,
        .closeBrace
      ],
      Program(
        Function(
          "main",
          Statement.return( Expression.integerConstant(0))
        )
      )
    )
  }
}

// MARK: Private
private extension TestParser {
  private func testExpression(_ tokens: [CToken], _ expected: Expression) {
    self.testParse(tokens, expected, self.parser.parseExpression)
  }

  private func testExpression(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseExpression, throwsError: err)
  }

  private func testStatement(_ tokens: [CToken], _ expected: Statement) {
    self.testParse(tokens, expected, self.parser.parseStatement)
  }

  private func testStatement(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseStatement, throwsError: err)
  }

  private func testFunction(_ tokens: [CToken], _ expected: Function) {
    self.testParse(tokens, expected, self.parser.parseFunction)
  }

  private func testFunction(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseFunction, throwsError: err)
  }

  private func testProgram(_ tokens: [CToken], _ expected: Program) {
    self.testParse(tokens, expected, self.parser.parse)
  }

  private func testProgram(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parse, throwsError: err)
  }

  // Check that the tokens can be parsed
  private func testParse<T: Equatable & PrettyPrintable>(
    _ tokens: [CToken],
    _ expected: T,
    _ parser: (TokenSource) throws -> T
  ) {
    let tokenStream = TestTokenStream(tokens)
    do {
      let out = try parser(tokenStream)
      AssertASTEqual(out, expected)
      return
    } catch ParseError.unexpectedToken {
       print("Unexpected token: \(tokenStream.current?.debugDescription ?? "")")
    } catch ParseError.overflow {
      print("Overflow: \(tokenStream.current?.debugDescription ?? "")")
    } catch {
      print("Unhandled exception!")
    }
    XCTFail("Parsing failed")
  }

  // Check that trying to parse the tokens throws an error
  private func testParse<T: Equatable & PrettyPrintable>(
    _ tokens: [CToken],
    _ parser: (TokenSource) throws -> T,
    throwsError error: ParseError
  ) {
    let tokenStream = TestTokenStream(tokens)
    var thrownError: Error?
    XCTAssertThrowsError(try parser(tokenStream)) {
      thrownError = $0
    }
    XCTAssert(thrownError is ParseError)
    XCTAssertEqual(thrownError as? ParseError, error)
  }
}

// Convenient replacement for XCTAssertEqual when dealing with ASTs.
// When the test fails, this will pretty print the tree-- much nicer for debugging!
fileprivate func AssertASTEqual<T: Equatable & PrettyPrintable>(
  _ lhs: T?,
  _ rhs: T?,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  if lhs == rhs { return }
  XCTFail("""
    XCTAssertion fail.

    Abstract Syntax Trees do not match:

    \(lhs?.pretty() ?? "nil")

    does not equal

    \(rhs?.pretty() ?? "nil")\n
    """,
    file: file,
    line: line
  )
}