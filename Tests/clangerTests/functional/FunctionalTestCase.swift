import XCTest
import class Foundation.Bundle

class FunctionalTestCase: XCTestCase {
  // Compiles the given file, runs the executable, and checks the return code
  internal func compileAndAssert(_ file: String, returns expectedReturnCode: Int32) {
    // Compile the file
    let exePath = "out"
    try! self.runClangerCompile(c: file, out: exePath)

    // Run the executable
    let exe = URL(fileURLWithPath: exePath)
    let returnCode = try! self.runExecutable(path: exe, args: [])
    XCTAssert(FileManager.default.fileExists(atPath: exe.path), "Failed to generate executable")

    // Cleanup
    try! FileManager.default.removeItem(atPath: exe.path)

    XCTAssertEqual(returnCode, expectedReturnCode)
  }

  // Runs clanger with the given `args`, returning status
  @discardableResult
  private func runClangerCompile(c: String, out: String) throws -> Int32? {
    let clanger = productsDirectory.appendingPathComponent("clanger")
    let args = ["compile", c, "--out", out]
    return try self.runExecutable(path: clanger, args: args)
 }

  // Runs the executable at `path` with the given `args`, returning the status
  @discardableResult
  private func runExecutable(path: URL, args: [String]) throws -> Int32? {
    // Some of the APIs that we use below are available in macOS 10.13 and above.
    guard #available(macOS 10.13, *) else {
      return nil
    }
    guard !targettingMacCatalyst() else {
      // Mac Catalyst won't have `Process`, but it is supported for executables.
      print("Mac Catalyst is not supported")
      return nil
    }

    let process = Process()
    process.executableURL = path
    process.arguments = args

    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    return process.terminationStatus
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
      for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
        return bundle.bundleURL.deletingLastPathComponent()
      }
      fatalError("couldn't find the products directory")
    #else
      return Bundle.main.bundleURL
    #endif
  }
}

fileprivate func targettingMacCatalyst() -> Bool
{
    #if targetEnvironment(macCatalyst)
      return true
    #endif
    return false
}