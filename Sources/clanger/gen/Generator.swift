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
        builder.movq(val, .rax)
      case .unaryOp(let op, let expr):
        switch op {
          case .negation:
            genExpression(expr)
            builder.neg(.rax)
          case .bitwiseComplement:
            genExpression(expr)
            builder.not(.rax)
          case .logicalNegation:
            // %rax => 1 iff expr == 0
            genExpression(expr)
            builder.cmpq(0, .rax)
            builder.movq(0, .rax) // sete can only check eax's lsb (al)
            builder.sete(.al)
        }
      case .binaryOp(let op, let exprA, let exprB):
        switch op {
          case .add:
            genExpression(exprA)
            builder.pushq(.rax)
            genExpression(exprB)
            builder.popq(.rcx)
            builder.addq(.rcx, .rax)
          case .multiply:
            genExpression(exprA)
            builder.pushq(.rax)
            genExpression(exprB)
            builder.popq(.rcx)
            builder.imul(.rcx, .rax)
          case .minus:
            genExpression(exprB)
            builder.pushq(.rax)
            genExpression(exprA)
            builder.popq(.rcx)
            builder.sub(.rcx, .rax)
          case .divide:
            builder.pushq(.rbp)
            defer { builder.popq(.rbp) }
            genExpression(exprB)
            builder.movq(.rax, .rbp)
            genExpression(exprA)
            builder.cqto()
            builder.idivq(.rbp)
        }
    }
  }

  // MARK: - Private
  private let builder: X86_64Builder
}