import Foundation
import XCTest

@testable import clanger

class FunctionalTests: XCTestCase {
  func testReturnInt() {
    let source = """
      int main() {
        return 42;
      }
    """
    XCTAssertEqual(execute(source), 42)
  }

  func testReturnNegative() {
    let source = """
      int main() {
        return -43;
      }
    """
    XCTAssertEqual(execute(source), 213)
  }

  func testReturnBitwiseComplement() {
    let source = """
      int main() {
        return ~4;
      }
    """
    // ~4 => 251 for 8 bits
    XCTAssertEqual(execute(source), 251)
  }

  func testReturnLogicalNegation() {
    let source = """
      int main() {
        return !1;
      }
    """
    XCTAssertEqual(execute(source), 0)
  }

  func testReturnNestedLogicalNegation() {
    let source = """
      int main() {
        return !!1;
      }
    """
    XCTAssertEqual(execute(source), 1)
  }

  func testReturnAddition() {
    let source = """
      int main() {
        return 32 + 10;
      }
    """
    XCTAssertEqual(execute(source), 42)
  }

  func testReturnMultiplication() {
    let source = """
      int main() {
        return 4 * 10;
      }
    """
    XCTAssertEqual(execute(source), 40)
  }

  func testReturnSubtraction() {
    let source = """
      int main() {
        return 255 - 55;
      }
    """
    XCTAssertEqual(execute(source), 200)
  }
}


private extension FunctionalTests {
  func execute(_ source: String) -> Int? {
    return execute(source)?.returnCode
  }

  func execute(_ source: String) -> String? {
    return execute(source)?.stdout
  }

  func execute(_ source: String) -> ExecOutcome? {
    let tmpSrc = tmpPath()
    let tmpExec = tmpPath()
    defer {
      [tmpSrc, tmpExec].forEach({
        try! FileManager.default.removeItem(atPath: $0)
      })
    }

    try! source.write(toFile: tmpSrc, atomically: false, encoding: .utf8)

    guard Compiler().compile(tmpSrc, tmpExec) else {
      return nil
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: tmpExec)
    let pipe = Pipe()
    process.standardOutput = pipe
    try! process.run()
    process.waitUntilExit()

    let stdout = String(data:
      pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8
    )!
    return ExecOutcome(stdout: stdout, returnCode: Int(process.terminationStatus))
  }

  struct ExecOutcome {
    let stdout: String
    let returnCode: Int
  }

  func tmpPath() -> String {
    return URL(fileURLWithPath:
      NSTemporaryDirectory()
    ).appendingPathComponent(UUID().uuidString).path
  }
}
