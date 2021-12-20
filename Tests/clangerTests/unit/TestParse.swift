import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the output of the Lex step and the Parser.
/// Takes C tokens and checks that the correct abstract-syntax tree is created.
class TestParser: XCTestCase {
  private let parser = Parser()
}

// MARK: - Expressions
extension TestParser {
  // MARK: Integer constants
  func testIntegerConstantExpressions() {
    for i in stride(from: 0, to: 32, by: 1) {
      let n = Int32(UInt64((1 << i) - 1))
      let decimal = String(n)
      let hexadecimal = "0x" + String(n, radix: 16)
      let octal = "0" + String(n, radix: 8)
      for representation in [decimal, hexadecimal, octal] {
        testExpression([.intLiteral( representation )], .integerConstant(n))
      }
    }
  }

  func testIntegerConstantExpressionOverflow() {
    let tooBig = UInt64(Int32.max) + 1
    let decimal = String(tooBig)
    let hexadecimal = "0x" + String(tooBig, radix: 16)
    let octal = "0" + String(tooBig, radix: 8)
    for representation in [decimal, hexadecimal, octal] {
      testExpression([ .intLiteral(representation)], throwsError: .overflow)
    }
  }

  // MARK: Unary Ops
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
      testExpression(
        [tokOp, .intLiteral("1337")],
        .unaryOp(op, .integerConstant(1337))
      )
    }
  }

  func testUnaryOperatorExpressionsNested() {
    testExpression(
      [.hyphen, .hyphen, .intLiteral("0")],
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(0)))
    )
    testExpression(
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
      testExpression([tokOp], throwsError: .unexpectedToken)
      testExpression([tokOp, tokOp], throwsError: .unexpectedToken)
    }
  }

  // MARK: Binary Ops
  private func tokenBinaryOpPairs() -> [(CToken, Expression.BinaryOperator)] {
    return [
      // token      =>       operator
      (.addition,           .add),
      (.hyphen,             .minus),
      (.asterisk,           .multiply),
      (.division,           .divide),
      (.and,                .and),
      (.or,                 .or),
      (.lessThan,           .lessThan),
      (.greaterThan,        .greaterThan),
      (.lessThanOrEqual,    .lessThanOrEqual),
      (.greaterThanOrEqual, .greaterThanOrEqual),
    ]
  }

  func testBinaryOperatorExpressionsBasic() {
    // e.g., 1 + 2
    for (tokOp, op) in tokenBinaryOpPairs() {
      testExpression(
        [.intLiteral("1"), tokOp, .intLiteral("2")],
        .binaryOp(op, .integerConstant(1), .integerConstant(2))
      )
    }
  }

  func testBinaryOperatorExpressionsLeftAssociativity() {
    // e.g., 1 + 2 + 3
    for (tokOp, op) in tokenBinaryOpPairs() {
      testExpression(
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

  func testOperatorExpressionsPrecedence() {
    // Precedence ordering:
    //   1. brackets / unary-ops
    //   2. multiplication / division
    //   3. addition / subtraction
    //   4. relational ( < | > | <= | >= )
    //   5. equality ( == | != )
    //   6. logical-and
    //   7. logical-or

    //   1 || 2 && 3 != 4 >= 5 - (6 + 7) * ~8
    testExpression([
      .intLiteral("1"),
      .or,
      .intLiteral("2"),
      .and,
      .intLiteral("3"),
      .notEqual,
      .intLiteral("4"),
      .greaterThanOrEqual,
      .intLiteral("5"),
      .hyphen,
      .openParen,
      .intLiteral("6"),
      .addition,
      .intLiteral("7"),
      .closeParen,
      .asterisk,
      .bitwiseComplement,
      .intLiteral("8"),
    ],
      .binaryOp(
        .or,
        .integerConstant(1),
        .binaryOp(
          .and,
          .integerConstant(2),
          .binaryOp(
            .notEqual,
            .integerConstant(3),
            .binaryOp(
              .greaterThanOrEqual,
              .integerConstant(4),
              .binaryOp(
                .minus,
                .integerConstant(5),
                .binaryOp(
                  .multiply,
                  .binaryOp(
                    .add,
                    .integerConstant(6),
                    .integerConstant(7)
                  ),
                  .unaryOp(
                    .bitwiseComplement,
                    .integerConstant(8)
                  )
                )
              )
            )
          )
        )
      )
    )
  }

  func testBinaryOperatorExpressionsNested() {
    // braces e.g., 1 + ((2 + 3) + 4)
    for (tokOp, op) in tokenBinaryOpPairs() {
      testExpression([
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

  func testBinaryOperatorExpresionsMissingOp() {
    // __ + 2
    testExpression([.addition, .intLiteral("2")], throwsError: .unexpectedToken)
    // 2 + __
    testExpression([.intLiteral("2"), .addition], throwsError: .unexpectedToken)
  }
}

// MARK: - Statements
extension TestParser {
  func testReturnStatements() {
    // return 0;
    testStatement(
      [.keyword(.return), .intLiteral("0"), .semiColon],
      Statement.return( Expression.integerConstant(0) )
    )
  }

  func testMissingSemicolonStatement() {
    // return 1
    let statement = [
      CToken.keyword(.return),
      .intLiteral("1"),
    ]
    testStatement(statement, throwsError: .unexpectedToken)
  }

  func testReturnBinaryOp() {
    // return (1 + 2);
    testStatement([
      CToken.keyword(.return),
      .openParen,
      .intLiteral("1"),
      .addition,
      .intLiteral("2"),
      .closeParen,
      .semiColon
    ],
      .return(.binaryOp(.add, .integerConstant(1), .integerConstant(2)))
    )
  }

  func testIllFormedBracketStatement() {
    // return 1 (+ 2);
    let statement = [
      CToken.keyword(.return),
      .intLiteral("1"),
      .openParen,
      .addition,
      .intLiteral("2"),
      .closeParen,
      .semiColon
    ]
    testStatement(statement, throwsError: .unexpectedToken)
  }
}

// MARK: - Functions
extension TestParser {
  func testBasicFunction() {
    testFunction(
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

  // Note: the standard *does* allow main() to be written without a return.
  func testEmptyFunctionNotMain() {
    let f = [
      CToken.keyword(.int),
      .identifier("i_am_not_main"),
      .openParen,
      .closeParen,
      .openBrace,
      .closeBrace
    ]
    testFunction(f, throwsError: .unexpectedToken)
  }

  func testMissingOpenBraceFunction() {
    let f = [
      CToken.keyword(.int),
      .identifier("main"),
      .openParen,
      .closeParen,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]
    testFunction(f, throwsError: .unexpectedToken)
  }

  func testMissingCloseBraceFunction() {
    let f = [
      CToken.keyword(.int),
      .identifier("main"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
    ]
    testFunction(f, throwsError: .unexpectedToken)
  }

  func testMissingReturnTypeFunction() {
    let f = [
      CToken.identifier("main"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]
    testFunction(f, throwsError: .unexpectedToken)
  }

  func testMissingArgListFunction() {
    let f = [
      CToken.keyword(.int),
      .identifier("main"),
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]
    testFunction(f, throwsError: .unexpectedToken)
  }
}

// MARK: - Programs
extension TestParser {
  func testBasicProgram() {
    testProgram(
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

// MARK: - Private
private extension TestParser {
  private func testExpression(_ tokens: [CToken], _ expected: Expression) {
    testParse(tokens, expected, parser.parseExpression)
  }

  private func testExpression(_ tokens: [CToken], throwsError err: ParseError) {
    testParse(tokens, parser.parseExpression, throwsError: err)
  }

  private func testStatement(_ tokens: [CToken], _ expected: Statement) {
    testParse(tokens, expected, parser.parseStatement)
  }

  private func testStatement(_ tokens: [CToken], throwsError err: ParseError) {
    testParse(tokens, parser.parseStatement, throwsError: err)
  }

  private func testFunction(_ tokens: [CToken], _ expected: Function) {
    testParse(tokens, expected, parser.parseFunction)
  }

  private func testFunction(_ tokens: [CToken], throwsError err: ParseError) {
    testParse(tokens, parser.parseFunction, throwsError: err)
  }

  private func testProgram(_ tokens: [CToken], _ expected: Program) {
    testParse(tokens, expected, parser.parse)
  }

  private func testProgram(_ tokens: [CToken], throwsError err: ParseError) {
    testParse(tokens, parser.parse, throwsError: err)
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