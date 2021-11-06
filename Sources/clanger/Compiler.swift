import Foundation

public final class Compiler {
  /// Compiles a single file containing C code to x86 assembly.
  /// Returns early if the C file `path` doesn't exist.
  public func compile(_ sourcePath: String, _ outPath: String) {
    guard pathIsValid(sourcePath) else {
      logger.error("Invalid path for compile: \(sourcePath)")
      return
    }

    self.preprocess(sourcePath)

    guard let outputHandler = self.setupAssemblyOutput(sourcePath) else {
      logger.error("Failed to initialise ouput handler")
      return
    }
    defer { self.cleanup(outputHandler.path) }

    guard self.produceAssembly(sourcePath, outputHandler) else {
      logger.error("Failed to produce assembly")
      return
    }

    self.assemble(outputHandler.path, outPath)
  }

  /// Generates and pretty-prints an abstract-syntax-tree for the given source
  /// file, assuming it is valid C.
  public func producePrettyAST(_ sourcePath: String) {
    guard let ast = self.produceAst(sourcePath) else {
      logger.error("Failed to produce AST")
      return
    }
    print(ast.pretty())
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
    guard let ast = self.produceAst(sourcePath) else {
      return false
    }
    Generator(output).emitProgram(ast)
    return true
  }

  private func produceAst(_ sourcePath: String) -> Program? {
    guard let input = InputStream(fileAtPath: sourcePath) else {
      logger.error("Failed to initialise input stream for \(sourcePath)")
      return nil
    }

    let tokens = TokenSequence(CharacterStream(input))
    do {
      return try Parser().parse(tokens)
    } catch ParseError.unexpectedToken {
      logger.error("Unexpected token: \(tokens.debugContext)")
      return nil
    } catch ParseError.overflow {
      logger.error("Overflow: \(tokens.debugContext)")
      return nil
    } catch {
      logger.error("Unhandled error: \(error): \(tokens.debugContext)")
      return nil
    }
  }

  private func assemble(_ path: String, _ outPath: String) {
    // TODO: error handling
    systemCall("gcc \(path) -o \(outPath)")
  }

  private func cleanup(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }
}