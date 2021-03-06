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

  func testUnaryOpsNegation() {
    // -3
    testExpression(
      .unaryOp(.negation, .integerConstant(3)),
      """
      movq  $3, %rax
      neg   %rax
      """
    )
  }

  func testUnaryOpsBitwiseComplement() {
    // ~7
    testExpression(
      .unaryOp(.bitwiseComplement, .integerConstant(7)),
      """
      movq  $7, %rax
      not   %rax
      """
    )
  }

  func testUnaryOpsLogicalNegation() {
    // !1
    testExpression(
      .unaryOp(.logicalNegation, .integerConstant(1)),
      """
      movq  $1, %rax
      cmpq  $0, %rax
      movq  $0, %rax
      sete  %al
      """
    )
  }

  func testUnaryOpsNested() {
    // --842
    testExpression(
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(842))),
      """
      movq  $842, %rax
      neg   %rax
      neg   %rax
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
      movq  $1337, %rax
      cmpq  $0, %rax
      movq  $0, %rax
      sete  %al
      cmpq  $0, %rax
      movq  $0, %rax
      sete  %al
      """
    )
  }

  func testBinaryOpsAddition() {
    // 1 + 2
    testExpression(
      .binaryOp(.add, .integerConstant(1), .integerConstant(2)),
      """
      movq  $1, %rax
      pushq %rax
      movq  $2, %rax
      popq  %rcx
      addq  %rcx, %rax
      """
    )
  }

  func testBinaryOpsMultiplication() {
    // 2 * 3
    testExpression(
      .binaryOp(.multiply, .integerConstant(2), .integerConstant(3)),
      """
      movq  $2, %rax
      pushq %rax
      movq  $3, %rax
      popq  %rcx
      imul  %rcx, %rax
      """
    )
  }

  func testBinaryOpsSubtraction() {
    // 42 - 2
    testExpression(
      .binaryOp(.minus, .integerConstant(42), .integerConstant(2)),
      """
      movq  $2, %rax
      pushq %rax
      movq  $42, %rax
      popq  %rcx
      sub   %rcx, %rax
      """
    )
  }

  func testBinaryOpsDivision() {
    // 600 / 12
    testExpression(
      .binaryOp(.divide, .integerConstant(600), .integerConstant(12)),
      """
      pushq  %rbp
      movq   $12, %rax
      movq   %rax, %rbp
      movq   $600, %rax
      cqto
      idivq  %rbp
      popq   %rbp
      """
    )
  }

  func testBinaryOpsComparisons() {
    // 2 == 3, 2 != 3, 2 < 3, 2 <= 3, 2 > 3, 2 >= 3
    for (op, inst) in Array<(Expression.BinaryOperator, String)>([
      (.equal,              "sete"),
      (.notEqual,           "setne"),
      (.lessThan,           "setl"),
      (.lessThanOrEqual,    "setle"),
      (.greaterThan,        "setg"),
      (.greaterThanOrEqual, "setge"),
    ]) {
      testExpression(
        .binaryOp(op, .integerConstant(2), .integerConstant(3)),
        """
        movq     $2, %rax
        pushq    %rax
        movq     $3, %rax
        popq     %rcx
        cmpq     %rax, %rcx
        movq     $0, %rax
        \(inst)  %al
        """
      )
    }
  }

  func testBinaryOpsOr() {
    // 99 || 25
    testExpression(
      .binaryOp(.or, .integerConstant(99), .integerConstant(25)),
      """
        movq   $99, %rax
        cmpq   $0, %rax
        je     _disjunct2
        movq   $1, %rax
        jmp    _end
      _disjunct2:
        movq   $25, %rax
        cmpq   $0, %rax
        movq   $0, %rax
        setne  %al
      _end:
      """
    )
  }

  func testBinaryOpsAnd() {
    // 100 && 200
    testExpression(
      .binaryOp(.and, .integerConstant(100), .integerConstant(200)),
      """
        movq   $100, %rax
        cmpq   $0, %rax
        jne    _conjunct2
        jmp    _end
      _conjunct2:
        movq   $200, %rax
        cmpq   $0, %rax
        movq   $0, %rax
        setne  %al
      _end:
      """
    )
  }

  // MARK: Statements
  func testReturn() {
    // return 42;
    testStatement(
      Statement.return( Expression.integerConstant(42)),
      """
      movq  $42, %rax
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
          movq  $42, %rax
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
          movq  $0, %rax
          ret
      """
    )
  }
}

// MARK: Private
private extension TestGenerator {
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
  let actualTokens = Array(AssemblyTokenSequence(CharacterStream(InputStream(string: actual))))
  let expectedTokens = Array(AssemblyTokenSequence(CharacterStream(InputStream(string: expected))))

  func failStr() -> String {
    return """
    \(actual)

    does not equal expected:

    \(expected)\n
    """
  }

  guard actualTokens.count == expectedTokens.count else {
    XCTFail(" XCTAssertion fail: assembly not equal:\n\n\(failStr())")
    return
  }

  for (actualToken, expectedToken) in zip(actualTokens, expectedTokens) {
    if actualToken != expectedToken {
      // We don't care about the contents of labels or identifiers. The generator
      // will increment a counter at the end of each new label to keep them
      // unique. This will mess with the test.
      if case .label(_) = actualToken, case .label(_) = expectedToken {
        continue
      }
      if case .identifier(_) = actualToken, case .identifier(_) = expectedToken {
        continue
      }
      XCTFail("""
        XCTAssertion fail: assembly not equal at \(actualToken) (expected \(expectedToken)):

        \(failStr())
        """,
        file: file,
        line: line
      )
    }
  }
}
