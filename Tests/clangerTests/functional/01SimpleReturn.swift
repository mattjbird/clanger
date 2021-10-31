import Foundation
import XCTest

@testable import clanger

class test01SimpleReturn: XCTestCase {
  func testSimpleReturn() {
    let program = """
      int main() {
        return 9001;
      }
    """
    let assembly = """
          .globl _main
      _main:
          movl    $9001, %eax
          ret
      """
    let tokens = TokenSequence(CharacterStream(InputStream(string: program)))
    let ast = try! Parser().parse(tokens)
    let out = TestOutputHandler()
    Generator(out).emitProgram(ast)
    XCTAssertEqual(out.value, assembly)
  }
}