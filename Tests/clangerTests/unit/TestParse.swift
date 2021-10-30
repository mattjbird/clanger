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
      var thrownError: Error?
      let overflowing = TestTokenStream([ .intLiteral(representation) ])
      XCTAssertThrowsError(try self.parser.parseExpression(overflowing)) {
        thrownError = $0
      }
      XCTAssert(thrownError is ParseError)
      XCTAssertEqual(thrownError as? ParseError, ParseError.overflow)
    }
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
    self.test(tokens, expected, self.parser.parseExpression)
  }

  private func testStatement(_ tokens: [CToken], _ expected: Statement) {
    self.test(tokens, expected, self.parser.parseStatement)
  }

  private func testFunction(_ tokens: [CToken], _ expected: Function) {
    self.test(tokens, expected, self.parser.parseFunction)
  }

  private func testProgram(_ tokens: [CToken], _ expected: Program) {
    self.test(tokens, expected, self.parser.parse)
  }

  private func test<T: Equatable & PrettyPrintable>(
    _ tokens: [CToken],
    _ expected: T,
    _ parser: (TokenSource) throws -> T
  ) {
    // Check that the tokens can be parsed
    let out = try? parser(TestTokenStream(tokens))
    XCTAssertEqual(out, expected)

    // Ensure that every incorrect combination of the tokens fails
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
