import Foundation
import XCTest

@testable import clanger

/// Note: this is a test for test utils, rather than the clanger code per se.
/// For the Generation tests we tokenise the assembly we're receiving and
/// expecting to check for equality. This test verifies that the tokenisation
/// is correct.
class TestAssemblyLexer: XCTestCase {
  func testDirectives() {
    testLex(".globl", [.directive(.globl)])
  }

  func testKeywords() {
    testLex("movl", [.keyword(.movl)])
    testLex("ret", [.keyword(.ret)])
    testLex("neg", [.keyword(.neg)])
    testLex("not", [.keyword(.not)])
    testLex("cmpl", [.keyword(.cmpl)])
    testLex("sete", [.keyword(.sete)])
    testLex("push", [.keyword(.push)])
    testLex("pop", [.keyword(.pop)])
  }

  func testPunctuation() {
    testLex(",", [.punctuation(.comma)])
    testLex(":", [.punctuation(.colon)])
  }

  func testIdentifier() {
    testLex("hello", [.identifier("hello")])
  }

  func testDeclaration() {
    testLex(
      """
        .globl _meaning_of_life
      _meaning_of_life:
      """,
      [
        .directive(.globl),
        .identifier("_meaning_of_life"),
        .identifier("_meaning_of_life"),
        .punctuation(.colon),
      ]
    )
  }

  func testReturnLiteral() {
    testLex("""
      movl  $9, %eax
      ret
      """,
      [
        .keyword(.movl),
        .literal("9"),
        .punctuation(.comma),
        .register(.eax),
        .keyword(.ret)
      ]
    )
  }

  func testLogicalNegation() {
    testLex("""
      movl    $1, %eax
      cmpl    $0, %eax
      movl    $0, %eax
      sete    %al
      """,
      [
        .keyword(.movl),
        .literal("1"),
        .punctuation(.comma),
        .register(.eax),

        .keyword(.cmpl),
        .literal("0"),
        .punctuation(.comma),
        .register(.eax),

        .keyword(.movl),
        .literal("0"),
        .punctuation(.comma),
        .register(.eax),

        .keyword(.sete),
        .register(.al),
    ])
  }

  func testAddition() {
    testLex("""
      movl    $1, %eax
      push    %eax
      movl    $2, %eax
      pop     %ecx
      addl    %ecx, %eax
    """,
      [
        .keyword(.movl),
        .literal("1"),
        .punctuation(.comma),
        .register(.eax),

        .keyword(.push),
        .register(.eax),

        .keyword(.movl),
        .literal("2"),
        .punctuation(.comma),
        .register(.eax),

        .keyword(.pop),
        .register(.ecx),

        .keyword(.addl),
        .register(.ecx),
        .punctuation(.comma),
        .register(.eax)
      ]
    )
  }

  private func testLex(_ src: String, _ expected: [AssemblyToken]) {
    let tokens = AssemblyTokenSequence(CharacterStream(InputStream(string: src)))
    XCTAssertEqual(Array(tokens), expected)
  }
}