import Foundation
import XCTest

@testable import clanger

class FunctionalTests: XCTestCase {
  func testReturnInt() {
    XCTAssertEqual(compile("int main() { return 42; }"), 42)
  }

  func testReturnNegative() {
    XCTAssertEqual(compile("int main() { return -43; }"), 213)
  }

  func testReturnBitwiseComplement() {
    // ~4 => 251 for 8 bits
    XCTAssertEqual(compile("int main() { return ~4; }"), 251)
  }

  func testReturnLogicalNegation() {
    XCTAssertEqual(compile("int main() { return !1; }"), 0)
  }

  // MARK: - Private
  private func compile(_ str: String) -> Int32 {
    let tmpIn = "tmp-in"
    defer { try! FileManager.default.removeItem(atPath: tmpIn) }
    try! str.write(toFile: tmpIn, atomically: false, encoding: .utf8)

    let tmpOut = "tmp-out"
    defer { try! FileManager.default.removeItem(atPath: tmpOut) }

    Compiler().compile(tmpIn, tmpOut)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: tmpOut)
    let pipe = Pipe()
    process.standardOutput = pipe
    try! process.run()
    process.waitUntilExit()

    return process.terminationStatus

    // Note: in the future we can return the printed output like this
    //let data = pipe.fileHandleForReading.readDataToEndOfFile()
    //return String(data: data, encoding: .utf8)!
  }
}
