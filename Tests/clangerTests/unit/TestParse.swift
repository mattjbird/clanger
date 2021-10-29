import Foundation
import XCTest

@testable import clanger

class TestParser: XCTestCase {
  let parser = Parser()

  func testReturn0() {
    let program = try? parser.parse(TestTokenStream([
      .keyword(.int),
      .identifier("main"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]))
    XCTAssertNotEqual(program, nil)

    let expected = Program(
      Function(
        "main",
        Statement.return(
          Expression.integerConstant(0)
        )
      )
    )
    XCTAssertEqual(program, expected)
  }

  func testMissingComponents() {
    // Each token here is individually necessary
    let goodTokens: [CToken] = [
      .keyword(.int),
      .identifier("main"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]
    // ... so make sure that removing it causes a parsing error
    for i in stride(from: 0, to: goodTokens.count - 1, by: 1) {
      var badTokens = goodTokens
      badTokens.remove(at: i)
      let ast = try? parser.parse(TestTokenStream(badTokens))
      XCTAssertEqual(ast, nil)
    }
  }
}
