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
            builder.movq(0, .rax)
            builder.sete(.al)
        }
      case .binaryOp(let op, let exprA, let exprB):
        /// Generates e1 => rcx and e2 => rax
        func stage(rcx e1: Expression, rax e2: Expression) {
          genExpression(e1)
          builder.pushq(.rax)
          genExpression(e2)
          builder.popq(.rcx)
        }
        switch op {
          case .add:
            stage(rcx: exprA, rax: exprB)
            builder.addq(.rcx, .rax)
          case .multiply:
            stage(rcx: exprA, rax: exprB)
            builder.imul(.rcx, .rax)
          case .minus:
            stage(rcx: exprB, rax: exprA)
            builder.sub(.rcx, .rax)
          case .divide:
            builder.pushq(.rbp)
            defer { builder.popq(.rbp) }
            genExpression(exprB)
            builder.movq(.rax, .rbp)
            genExpression(exprA)
            builder.cqto()
            builder.idivq(.rbp)
          case .equal,
               .notEqual,
               .lessThan,
               .lessThanOrEqual,
               .greaterThan,
               .greaterThanOrEqual:
            stage(rcx: exprA, rax: exprB)
            builder.cmpq(.rax, .rcx)
            builder.movq(0, .rax)
            switch op {
              case .equal:              builder.sete(.al)
              case .notEqual:           builder.setne(.al)
              case .lessThan:           builder.setl(.al)
              case .lessThanOrEqual:    builder.setle(.al)
              case .greaterThan:        builder.setg(.al)
              case .greaterThanOrEqual: builder.setge(.al)
              default:                  break
            }
          case .and:
            fallthrough
          case .or:
            fatalError("Unimplemented")
        }
    }
  }

  // MARK: - Private
  private let builder: X86_64Builder
}