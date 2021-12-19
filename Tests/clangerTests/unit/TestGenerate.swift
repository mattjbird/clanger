import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the Parser and the assembly Generator
/// Takes ASTs and tests that they're correctly transformed into assembly.
class TestGenerator: XCTestCase {
  // MARK: Expressions
  func testConstants() {
    testExpression( .integerConstant(9001), "movq  $9001, %rax" )
  }

  func testUnaryOps() {
    // -3
    testExpression(
      .unaryOp(.negation, .integerConstant(3)),
      """
      movq    $3, %rax
      neg     %rax
      """
    )
    // ~7
    testExpression(
      .unaryOp(.bitwiseComplement, .integerConstant(7)),
      """
      movq    $7, %rax
      not     %rax
      """
    )
    // !1
    testExpression(
      .unaryOp(.logicalNegation, .integerConstant(1)),
      """
      movq    $1, %rax
      cmpl    $0, %rax
      movq    $0, %rax
      sete    %al
      """
    )

    // Nested
    // --842
    testExpression(
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(842))),
      """
      movq    $842, %rax
      neg     %rax
      neg     %rax
      """
    )
    // !!1337
    testExpression(
      .unaryOp(
        .logicalNegation,
        .unaryOp(
          .logicalNegation,
          .integerConstant(1337)
        )
      ),
      """
      movq    $1337, %rax
      cmpl    $0, %rax
      movq    $0, %rax
      sete    %al
      cmpl    $0, %rax
      movq    $0, %rax
      sete    %al
      """
    )
  }

  // MARK: Statements
  func testReturn() {
    // return 42
    testStatement(
      Statement.return( Expression.integerConstant(42)),
      """
      movq    $42, %rax
      ret
      """
    )
  }

  // MARK: Functions
  func testFunctionSimpleReturn() {
    testFunction(
      Function(
        "meaning_of_life",
        Statement.return( Expression.integerConstant(42))
      ),
      """
          .globl _meaning_of_life
      _meaning_of_life:
          movq    $42, %rax
          ret
      """
    )
  }

  // Programs
  func testReturn0() {
    testProgram(
      Program(
        Function(
          "main",
          Statement.return( Expression.integerConstant(0))
        )
      ),
      """
          .globl _main
      _main:
          movq    $0, %rax
          ret
      """
    )
  }

  // MARK: - Private
  private func testProgram(_ program: Program, _ expected: String) {
    test({ $0.genProgram(program) }, expected)
  }

  private func testFunction(_ function: Function, _ expected: String) {
    test({ $0.genFunction(function) }, expected)
  }

  private func testStatement(_ statement: Statement, _ expected: String) {
    test({ $0.genStatement(statement) }, expected)
  }

  private func testExpression(_ expression: Expression, _ expected: String) {
    test({ $0.genExpression(expression) }, expected)
  }

  private func test(_ genFunction: (Generator) -> (), _ expected: String) {
    let out = TestOutputHandler()
    let gen = Generator(out)
    genFunction(gen)
    AssertAssemblyEqual(out.value, expected)
  }
}

fileprivate func AssertAssemblyEqual(
  _ actual: String,
  _ expected: String,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  let actualTokens = AssemblyTokenSequence(CharacterStream(InputStream(string: actual)))
  let expectedTokens = AssemblyTokenSequence(CharacterStream(InputStream(string: expected)))
  for (actualToken, expectedToken) in zip(actualTokens, expectedTokens) {
    if actualToken != expectedToken {
      XCTFail("""
        XCTAssertion fail: assembly not equal at \(actualToken) (expected \(expectedToken)):

        \(actual)

        does not equal expected:

        \(expected)\n
        """,
        file: file,
        line: line
      )
    }
  }
}
