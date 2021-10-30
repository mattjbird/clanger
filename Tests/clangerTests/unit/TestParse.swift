import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the output of the Lex step and the Parser
class TestParser: XCTestCase {
  // MARK: Expressions
  func testIntegerConstantExpressions() {
    // Decimals
    self.testExpression([.intLiteral("42")], .integerConstant(42))
    // Hexadecimal
    //self.testExpression([.intLiteral("0x42")], .integerConstant(66))
    // Octal
    //self.testExpression([.intLiteral("042")], .integerConstant(34))

    // Overflow
    // TODO
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

  private func testExpression(_ tokens: [CToken], _ expected: Expression?) {
    self.test(tokens, expected, self.parser.parseExpression)
  }

  private func testStatement(_ tokens: [CToken], _ expected: Statement?) {
    self.test(tokens, expected, self.parser.parseStatement)
  }

  private func testFunction(_ tokens: [CToken], _ expected: Function?) {
    self.test(tokens, expected, self.parser.parseFunction)
  }

  private func testProgram(_ tokens: [CToken], _ expected: Program?) {
    self.test(tokens, expected, self.parser.parse)
  }

  private func test<T: Equatable>(
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
      XCTAssertEqual(try? parser(TestTokenStream(badTokens)), nil)
    }
  }
}
