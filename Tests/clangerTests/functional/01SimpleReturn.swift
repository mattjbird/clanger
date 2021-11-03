import Foundation
import XCTest

@testable import clanger

/* Replace this with a test which compiles and runs a file
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
          ret\n
      """
    let output = TestOutputHandler()
    let compiler = Compiler(output: output)
    try! compiler.compile(CharacterStream(InputStream(string: program)))
    XCTAssertEqual(output.value, assembly)
  }
}
*/