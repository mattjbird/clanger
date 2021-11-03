import Foundation

/// Transforms a `Program` AST into 64-bit x86 assembly
public final class Generator {
  public init(_ out: OutputHandler) {
    self.out = out
  }

  /// Converts the `Program` to x86 assembly with indentation.
  public func emitProgram(_ program: Program) {
    emitFunction(program.function)
  }

  // MARK: - Internal
  internal func emitFunction(_ function: Function) {
    self.emit("    .globl _\(function.name)")  // make func visible to linker
    self.emit("_\(function.name):")            // label
    self.emitStatement(function.body)
  }

  internal func emitStatement(_ statement: Statement) {
    switch statement {
      case .return(let expression):
        // TODO: this is only going to work when returning a constant
        let value = generateExpression(expression)
        self.emit("    movl    $\(value), %eax") // val => return register
        self.emit("    ret")                     // return
    }
  }

  internal func generateExpression(_ expression: Expression) -> String {
    switch expression {
      case .integerConstant(let value):
        return String(value)
    }
  }

  // MARK: - Private
  private let out: OutputHandler

  private func emit(_ str: String) {
    self.out.emit(str + "\n")
  }
}
