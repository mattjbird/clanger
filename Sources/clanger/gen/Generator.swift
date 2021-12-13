import Foundation

/// Transforms a `Program` AST into 64-bit x86 assembly
public final class Generator {
  public init(_ out: OutputHandler) {
    builder = X86_64Builder(out)
  }

  /// Converts the `Program` to x86_64 AT&T assembly.
  public func genProgram(_ prog: Program) {
    genFunction(prog.function)
  }

  // MARK: - Internal
  func genFunction(_ f: Function) {
    builder.global(f.name)
    builder.label(f.name)
    genStatement(f.body)
  }

  func genStatement(_ statement: Statement) {
    switch statement {
      case .return(let expr):
        genExpression(expr)
        builder.ret()
    }
  }

  func genExpression(_ expr: Expression) {
    switch expr {
      case .integerConstant(let val):
        builder.movl(val, .eax)
      case .unaryOp(let op, let expr):
        switch op {
          case .negation:
            genExpression(expr)
            builder.neg(.eax)
          case .bitwiseComplement:
            genExpression(expr)
            builder.not(.eax)
          case .logicalNegation:
            // %eax => 1 iff expr == 0
            genExpression(expr)
            builder.cmpl(0, .eax)
            builder.movl(0, .eax) // sete can only check eax's lsb (al)
            builder.sete(.al)
        }
      case .binaryOp(_, _, _):
        fatalError("Unimplemented binary op!")
    }
  }

  // MARK: - Private
  private let builder: X86_64Builder
}
