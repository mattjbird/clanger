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

    guard let outputHandler = self.setupAssemblyOutput(path) else {
      logger.error("Failed to initialise ouput handler")
      return
    }
    defer { self.cleanup(outputHandler.path) }

    guard self.produceAssembly(path, outputHandler) else {
      logger.error("Failed to produce assembly")
      return
    }

    self.assemble(outputHandler.path, outPath)
  }

  // MARK: - Private
  private func pathIsValid(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  private func preprocess(_ path: String) {
    // TODO
  }

  private func setupAssemblyOutput(_ sourcePath: String) -> FileOutputHandler? {
    let outPath = sourcePath.appending(".s")
    return FileOutputHandler(outPath)
  }

  private func produceAssembly(_ sourcePath: String, _ output: FileOutputHandler) -> Bool {
    guard let input = InputStream(fileAtPath: sourcePath) else {
      logger.error("Failed to initialise input stream for \(sourcePath)")
      return false
    }

    let tokens = TokenSequence(CharacterStream(input))
    let ast: Program!
    do {
      try ast = Parser().parse(tokens)
    } catch ParseError.unexpectedToken {
      logger.error("Unexpected token: \(tokens.debugContext)")
      return false
    } catch ParseError.overflow {
      logger.error("Overflow: \(tokens.debugContext)")
      return false
    } catch {
      logger.error("Unhandled error: \(error): \(tokens.debugContext)")
      return false
    }
    Generator(output).emitProgram(ast)
    return true
  }

  private func assemble(_ path: String, _ outPath: String) {
    // TODO: error handling
    systemCall("gcc \(path) -o \(outPath)")
  }

  private func cleanup(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }
}