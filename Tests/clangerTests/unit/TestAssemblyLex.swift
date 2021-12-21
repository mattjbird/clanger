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
    testLex("addl", [.keyword(.addl)])
    testLex("addq", [.keyword(.addq)])
    testLex("and", [.keyword(.and)])
    testLex("call", [.keyword(.call)])
    testLex("cltq", [.keyword(.cltq)])
    testLex("cmova", [.keyword(.cmova)])
    testLex("cmovae", [.keyword(.cmovae)])
    testLex("cmovb", [.keyword(.cmovb)])
    testLex("cmovbe", [.keyword(.cmovbe)])
    testLex("cmove", [.keyword(.cmove)])
    testLex("cmovg", [.keyword(.cmovg)])
    testLex("cmovge", [.keyword(.cmovge)])
    testLex("cmovl", [.keyword(.cmovl)])
    testLex("cmovle", [.keyword(.cmovle)])
    testLex("cmovna", [.keyword(.cmovna)])
    testLex("cmovnae", [.keyword(.cmovnae)])
    testLex("cmovnb", [.keyword(.cmovnb)])
    testLex("cmovnbe", [.keyword(.cmovnbe)])
    testLex("cmovne", [.keyword(.cmovne)])
    testLex("cmovng", [.keyword(.cmovng)])
    testLex("cmovnge", [.keyword(.cmovnge)])
    testLex("cmovnl", [.keyword(.cmovnl)])
    testLex("cmovnle", [.keyword(.cmovnle)])
    testLex("cmovns", [.keyword(.cmovns)])
    testLex("cmovnz", [.keyword(.cmovnz)])
    testLex("cmovs", [.keyword(.cmovs)])
    testLex("cmovz", [.keyword(.cmovz)])
    testLex("cmp", [.keyword(.cmp)])
    testLex("cmpq", [.keyword(.cmpq)])
    testLex("cqto", [.keyword(.cqto)])
    testLex("cwtl", [.keyword(.cwtl)])
    testLex("dec", [.keyword(.dec)])
    testLex("idivl", [.keyword(.idivl)])
    testLex("idivq", [.keyword(.idivq)])
    testLex("imul", [.keyword(.imul)])
    testLex("inc", [.keyword(.inc)])
    testLex("ja", [.keyword(.ja)])
    testLex("jae", [.keyword(.jae)])
    testLex("jb", [.keyword(.jb)])
    testLex("jbe", [.keyword(.jbe)])
    testLex("je", [.keyword(.je)])
    testLex("jg", [.keyword(.jg)])
    testLex("jge", [.keyword(.jge)])
    testLex("jl", [.keyword(.jl)])
    testLex("jle", [.keyword(.jle)])
    testLex("jmp", [.keyword(.jmp)])
    testLex("jna", [.keyword(.jna)])
    testLex("jnae", [.keyword(.jnae)])
    testLex("jnb", [.keyword(.jnb)])
    testLex("jnbe", [.keyword(.jnbe)])
    testLex("jne", [.keyword(.jne)])
    testLex("jng", [.keyword(.jng)])
    testLex("jnge", [.keyword(.jnge)])
    testLex("jnl", [.keyword(.jnl)])
    testLex("jnle", [.keyword(.jnle)])
    testLex("jns", [.keyword(.jns)])
    testLex("jnz", [.keyword(.jnz)])
    testLex("js", [.keyword(.js)])
    testLex("jz", [.keyword(.jz)])
    testLex("leaq", [.keyword(.leaq)])
    testLex("leave", [.keyword(.leave)])
    testLex("movl", [.keyword(.movl)])
    testLex("movq", [.keyword(.movq)])
    testLex("neg", [.keyword(.neg)])
    testLex("not", [.keyword(.not)])
    testLex("or", [.keyword(.or)])
    testLex("popq", [.keyword(.popq)])
    testLex("pushq", [.keyword(.pushq)])
    testLex("ret", [.keyword(.ret)])
    testLex("sal", [.keyword(.sal)])
    testLex("sar", [.keyword(.sar)])
    testLex("seta", [.keyword(.seta)])
    testLex("setae", [.keyword(.setae)])
    testLex("setb", [.keyword(.setb)])
    testLex("setbe", [.keyword(.setbe)])
    testLex("sete", [.keyword(.sete)])
    testLex("setg", [.keyword(.setg)])
    testLex("setge", [.keyword(.setge)])
    testLex("setl", [.keyword(.setl)])
    testLex("setle", [.keyword(.setle)])
    testLex("setna", [.keyword(.setna)])
    testLex("setnae", [.keyword(.setnae)])
    testLex("setnb", [.keyword(.setnb)])
    testLex("setne", [.keyword(.setne)])
    testLex("setng", [.keyword(.setng)])
    testLex("setnge", [.keyword(.setnge)])
    testLex("setnle", [.keyword(.setnle)])
    testLex("setns", [.keyword(.setns)])
    testLex("setnz", [.keyword(.setnz)])
    testLex("setz", [.keyword(.setz)])
    testLex("shl", [.keyword(.shl)])
    testLex("shr", [.keyword(.shr)])
    testLex("sub", [.keyword(.sub)])
    testLex("subq", [.keyword(.subq)])
    testLex("test", [.keyword(.test)])
    testLex("xor", [.keyword(.xor)])
  }

  func testPunctuation() {
    testLex(",", [.punctuation(.comma)])
  }

  func testIdentifier() {
    testLex("_hello:", [.label("_hello")])
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
        .label("_meaning_of_life"),
      ]
    )
  }

  func testDirective() {
    testLex(
      "movq  $42, %rax",
      [.keyword(.movq), .literal("42"), .punctuation(.comma), .register(.rax)]
    )
  }

  func testMultiline() {
    testLex("""
      movq    $1, %rax
      cmpq    $0, %rax
      """,
      [
        .keyword(.movq),
        .literal("1"),
        .punctuation(.comma),
        .register(.rax),

        .keyword(.cmpq),
        .literal("0"),
        .punctuation(.comma),
        .register(.rax),
      ]
    )
  }

  func testWhitespace() {
    testLex("""
      movq $1,                %rax



      cmpq          $0,%rax
      """,
      [
        .keyword(.movq),
        .literal("1"),
        .punctuation(.comma),
        .register(.rax),

        .keyword(.cmpq),
        .literal("0"),
        .punctuation(.comma),
        .register(.rax),
      ]
    )
  }
}

// MARK: Private
private extension TestAssemblyLexer {
  private func testLex(_ src: String, _ expected: [AssemblyToken]) {
    func get(_ arr: [AssemblyToken], _ i: Int) -> AssemblyToken? {
      guard i < arr.count else { return nil }
      return arr[i]
    }
    let tokens = Array(AssemblyTokenSequence(CharacterStream(InputStream(string: src))))
    for i in stride(from: 0, through: max(tokens.count, expected.count) - 1, by: 1) {
      if i >= expected.count {
        return XCTFail("Expected end of tokens but got \(tokens[i])")
      }
      if i >= tokens.count {
        return XCTFail("Expected \(expected[i]) but got end of tokens")
      }
      XCTAssertEqual(tokens[i], expected[i])
    }
  }
}