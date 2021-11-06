import Foundation

public final class Compiler {
  /// Compiles a single file containing C code to x86 assembly.
  /// Returns early if the C file `path` doesn't exist.
  public func compile(_ path: String, _ outPath: String) {
    guard pathIsValid(path) else {
      logger.error("Invalid path for compile: \(path)")
      return
    }
    self.preprocess(path)
    guard let asmPath = self.produceAssembly(path) else {
      logger.error("Failed to produce assembly")
      return
    }
    self.assemble(asmPath, outPath)
    self.cleanup(asmPath)
  }

  // MARK: - Private
  private func pathIsValid(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  private func preprocess(_ path: String) {

  }

  private func produceAssembly(_ path: String) -> String? {
    guard let input = InputStream(fileAtPath: path) else {
      logger.error("Failed to initialise input stream for \(path)")
      return nil
    }

    // FIXME: do something better here
    let outputPath = path.replacingOccurrences(of: ".c", with: ".s")
    guard let output = FileOutputHandler(outputPath) else {
      logger.error("Failed to initialise output handler at \(outputPath)")
      return nil
    }
    let tokens = TokenSequence(CharacterStream(input))
    let ast: Program!
    do {
      try ast = Parser().parse(tokens)
    } catch {
      // TODO: error log
      return nil
    }
    Generator(output).emitProgram(ast)
    return outputPath
  }

  private func assemble(_ path: String, _ outPath: String) {
    systemCall("gcc \(path) -o \(outPath)")
  }

  private func cleanup(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }
}