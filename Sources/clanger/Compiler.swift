import Foundation

public final class Compiler {
  /// Compiles a C file to an executable, returning whether this was successful.
  @discardableResult
  public func compile(_ sourcePath: String, _ outPath: String) -> Bool {
    guard pathIsValid(sourcePath) else {
      logger.error("Invalid path for compile: \(sourcePath)")
      return false
    }

    self.preprocess(sourcePath)

    guard let outputHandler = self.setupAssemblyOutput(sourcePath) else {
      logger.error("Failed to initialise ouput handler")
      return false
    }
    defer { self.cleanup(outputHandler.path) }

    guard self.produceAssembly(sourcePath, outputHandler) else {
      logger.error("Failed to produce assembly")
      return false
    }

    self.assemble(outputHandler.path, outPath)
    return true
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
    Generator(output).genProgram(ast)
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
    let outcome = systemCall("gcc \(path) -o \(outPath)")
    if outcome.status != 0 {
      logger.error("Assembling error: \(outcome.output)")
    }
  }

  private func cleanup(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }
}