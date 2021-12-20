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

  // Tests every combination of operators for left-associativity
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

  // Tests every combination of operators and ensures that the correct operator
  // precedence level is respected.
  func testOperatorExpressionsPrecedence() {
    // Precedence ordering:
    //   1. brackets / unary-ops
    let unaryOps = tokenUnaryOpPairs()
    let binaryOpPrecedences: [[(CToken, Expression.BinaryOperator) ]] = [
      // 2. multiplication / division
      [(.asterisk, .multiply), (.division, .divide)],
      // 3. addition / subtraction
      [(.addition, .add), (.hyphen, .minus) ],
      // 4. relational ( < | > | <= | >= )
      [
        (.lessThan, .lessThan),
        (.greaterThan, .greaterThan),
        (.lessThanOrEqual, .lessThanOrEqual),
        (.greaterThanOrEqual, .greaterThanOrEqual)
      ],
      // 5. equality ( == | != )
      [(.equal, .equal), (.notEqual, .notEqual)],
      // 6. logical-and
      [(.and, .and)],
      // 7. logical-or
      [(.or, .or)]
    ]
    for first in unaryOps {
      for second in binaryOpPrecedences[0] {
        for third in binaryOpPrecedences[1] {
          for fourth in binaryOpPrecedences[2] {
            for fifth in binaryOpPrecedences[3] {
              for sixth in binaryOpPrecedences[4] {
                for seventh in binaryOpPrecedences[5] {
                    // e.g., 1 || 2 && 3 != 4 >= (5 + 6) * ~7
                    testExpression([
                      .intLiteral("1"),
                      seventh.0,
                      .intLiteral("2"),
                      sixth.0,
                      .intLiteral("3"),
                      fifth.0,
                      .intLiteral("4"),
                      fourth.0,
                      .openParen,
                      .intLiteral("5"),
                      third.0,
                      .intLiteral("6"),
                      .closeParen,
                      second.0,
                      first.0,
                      .intLiteral("7"),
                    ],
                      .binaryOp(
                        seventh.1,
                        .integerConstant(1),
                        .binaryOp(
                          sixth.1,
                          .integerConstant(2),
                          .binaryOp(
                            fifth.1,
                            .integerConstant(3),
                            .binaryOp(
                              fourth.1,
                              .integerConstant(4),
                              .binaryOp(
                                second.1,
                                .binaryOp(
                                  third.1,
                                  .integerConstant(5),
                                  .integerConstant(6)
                                ),
                                .unaryOp(
                                  first.1,
                                  .integerConstant(7)
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                }
              }
            }
          }
        }
      }
    }
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
    for (tokOp, _) in tokenBinaryOpPairs() {
      // __ OP 2
      if tokOp != .hyphen {
        // -2 is valid!
        testExpression([tokOp, .intLiteral("2")], throwsError: .unexpectedToken)
      }
      // 2 OP __
      testExpression([.intLiteral("2"), tokOp], throwsError: .unexpectedToken)
    }
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