import ArgumentParser
import Foundation
import Logging


// Entry-point for clanger
LoggingSystem.bootstrap(StreamLogHandler.standardError)
Clanger.main()


fileprivate struct Clanger: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Clanger is a compiler for a small (but growing!) subset of C",
    subcommands: [Compile.self, PrettyAST.self]
  )

  /// clanger compile <file>
  struct Compile: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Compiles the given C file"
    )

    @Argument(help: "The path to the file you'd like to compile")
    var target: String

    @Option(help: "The path for the outputted executable")
    var out: String = "out"

    /// Throws ValidationError if any of the `targets` don't exist
    func validate() throws {
      guard FileManager.default.fileExists(atPath: target) else {
        throw ValidationError("No such file at '\(target)'")
      }
    }

    func run() {
      Compiler().compile(self.target, self.out)
    }
  }

  /// clanger pretty-ast <file>
  struct PrettyAST: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Generates a pretty AST from the given C file"
    )

    @Argument(help: "The path to the file for which you want to generate an AST")
    var target: String

    /// Throws ValidationError if no file exists at `path`
    func validate() throws {
      guard FileManager.default.fileExists(atPath: target) else {
        throw ValidationError("No such file at '\(target)'")
      }
    }

    func run() {
      Compiler().producePrettyAST(self.target)
    }
  }
}