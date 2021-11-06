import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the output of the Lex step and the Parser
class TestParser: XCTestCase {
  // MARK: Expressions
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

  func testUnaryOperatorExpressions() {
    self.testExpression(
      [.negation, .intLiteral("1")],
      .unaryOp(.negation, .integerConstant(1))
    )
    self.testExpression(
      [.bitwiseComplement, .intLiteral("25")],
      .unaryOp(.bitwiseComplement, .integerConstant(25))
    )
    self.testExpression(
      [.logicalNegation, .intLiteral("0")],
      .unaryOp(.logicalNegation, .integerConstant(0))
    )

    // Nested
    self.testExpression(
      [.negation, .negation, .intLiteral("0")],
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(0)))
    )
    self.testExpression(
      [.bitwiseComplement, .negation, .logicalNegation, .intLiteral("9001")],
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

  // MARK: Statements
  func testReturnStatements() {
    self.testStatement(
      [.keyword(.return), .intLiteral("0"), .semiColon],
      Statement.return( Expression.integerConstant(0) )
    )
  }

  // MARK: Functions
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

  // MARK: Programs
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

  // MARK: - Private
  private let parser = Parser()

  private func testExpression(_ tokens: [CToken], _ expected: Expression) {
    self.testParse(tokens, expected, self.parser.parseExpression)
  }

  private func testExpression(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseExpression, throwsError: err)
  }

  private func testStatement(_ tokens: [CToken], _ expected: Statement) {
    self.testParse(tokens, expected, self.parser.parseStatement)
    self.testMissingComponentsFailParse(tokens, self.parser.parseStatement)
  }

  private func testStatement(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseStatement, throwsError: err)
  }

  private func testFunction(_ tokens: [CToken], _ expected: Function) {
    self.testParse(tokens, expected, self.parser.parseFunction)
    self.testMissingComponentsFailParse(tokens, self.parser.parseFunction)
  }

  private func testFunction(_ tokens: [CToken], throwsError err: ParseError) {
    self.testParse(tokens, self.parser.parseFunction, throwsError: err)
  }

  private func testProgram(_ tokens: [CToken], _ expected: Program) {
    self.testParse(tokens, expected, self.parser.parse)
    self.testMissingComponentsFailParse(tokens, self.parser.parse)
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
    let out = try? parser(TestTokenStream(tokens))
    AssertASTEqual(out, expected)
  }

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

  // Checks that every incorrect combination of the tokens fails.
  // Note: this assumes that each individual token is necessary to the token
  // stream. As things get more complex, this clearly isn't the case. For
  // instance, "-1" and "1" are both valid, so we can't check our parsing of
  // "-1" by removing "-" and asserting that the parsing fails! Hence why we
  // don't use this for expressions.
  private func testMissingComponentsFailParse<T: Equatable & PrettyPrintable>(
    _ tokens: [CToken],
    _ parser: (TokenSource) throws -> T
  ) {
    guard tokens.count > 1 else { return }
    for i in stride(from: 0, to: tokens.count - 1, by: 1) {
      var badTokens = tokens
      badTokens.remove(at: i)
      let tokenStream = TestTokenStream(badTokens)

      var thrownError: Error?
      XCTAssertThrowsError(try parser(tokenStream)) {
        thrownError = $0
      }
      XCTAssert(thrownError is ParseError)
      XCTAssertEqual(thrownError as? ParseError, ParseError.unexpectedToken)
    }
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