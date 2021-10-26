import Foundation
import XCTest

@testable import clanger

class TestCharacterStream: XCTestCase {
  func testEmpty() {
    let stream = CharacterStream(InputStream(string: ""))
    XCTAssert(stream.next() == nil)
    XCTAssert(stream.peek() == nil)
  }

  func testBasicLoop() {
    let string = "Hello, World!"
    let stream = CharacterStream(InputStream(string: string))
    let expected = Array(string)
    for i in stride(from: 0, to: string.count, by: 1) {
      XCTAssertEqual(stream.next(), expected[i])
    }
    XCTAssertEqual(stream.next(), nil)
  }

  func testPeek() {
    let string = "abcdefghijklmnopqrstuvwxyz"
    let stream = CharacterStream(InputStream(string: string))

    var peeked: Character? = string.first!
    for _ in 1 ... string.count {
      XCTAssertEqual(stream.next(), peeked)
      peeked = stream.peek()
    }
  }

  func testPaging() {
    let streamBufferCapacity = 512

    let sections: [Character] = ["a", "b", "c"]

    var str = String()
    str.reserveCapacity(streamBufferCapacity * sections.count)
    for char in sections {
      str += String(repeating: char, count: streamBufferCapacity)
    }

    let stream = CharacterStream(InputStream(string: str))
    for char in sections {
      for _ in 0 ..< streamBufferCapacity {
        XCTAssertEqual(stream.next(), char)
      }
    }
    XCTAssertEqual(stream.next(), nil)
    XCTAssertEqual(stream.peek(), nil)
  }

}
