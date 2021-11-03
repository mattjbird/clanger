import Foundation

public final class Compiler {
  /// Compiles a single file containing C code to x86 assembly.
  /// Returns early if the C file `path` doesn't exist.
  public func compile(_ path: String) {
    guard pathIsValid(path) else {
      return
    }
    self.preprocess(path)
    guard let asmPath = self.produceAssembly(path) else {
      // TOOD: error
      return
    }
    self.assemble(asmPath)
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
      // TODO: error log
      return nil
    }

    // FIXME: do something better here
    let outputPath = path.replacingOccurrences(of: ".c", with: ".s")
    guard let output = FileOutputHandler(outputPath) else {
      // TODO: error log
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

  private func assemble(_ path: String) {
    systemCall("gcc \(path) -o out")
  }

  private func cleanup(_ path: String) {
    // TODO: we need to wait for the assembly() command to finish before we
    // remove files
    //try? FileManager.default.removeItem(atPath: path)
  }
}