import Foundation
import XCTest

@testable import clanger

class TestLexer: XCTestCase {
    func testKeywords() {
        testLex("return", [.keyword(.return)])
        testLex("int", [.keyword(.int)])
    }

    func testPunctuation() {
        testLex("{}();", [
            .openBrace,
            .closeBrace,
            .openParen,
            .closeParen,
            .semiColon,
        ])
    }

    func testIntegerLiterals() {
        testLex("0", [.intLiteral(0)])
        var i = 1
        while i < UInt32.max {
            testLex("\(i)", [.intLiteral(i)])
            i *= 2
        }
    }

    func testIdentifiers() {
        testLex("mains f bar; aaaa", [
            .identifier("mains"),
            .identifier("f"),
            .identifier("bar"),
            .semiColon,
            .identifier("aaaa"),
        ])
    }

    func testWhitespaces() {
        testLex("return\nfoo\n{\n;", [
            .keyword(.return),
            .identifier("foo"),
            .openBrace,
            .semiColon,
        ])
        testLex("int      foo      {", [
            .keyword(.int),
            .identifier("foo"),
            .openBrace,
        ])
        testLex("f(){;}", [
            .identifier("f"),
            .openParen,
            .closeParen,
            .openBrace,
            .semiColon,
            .closeBrace,
        ])
    }

    func testCasing() {
        testLex("INT MAIN FOO", [
            .identifier("INT"),
            .identifier("MAIN"),
            .identifier("FOO"),
        ])
    }

    func testBasicFunction() {
        testLex("int f() { return 42; }", [
            .keyword(.int),
            .identifier("f"),
            .openParen,
            .closeParen,
            .openBrace,
            .keyword(.return),
            .intLiteral(42),
            .semiColon,
            .closeBrace,
        ])
    }

    private func testLex(_ src: String, _ expected: [CToken]) {
        let lexer = Lexer(CharacterStream(InputStream(string: src)))
        XCTAssertEqual(Array(lexer.tokens), expected)
    }
}
