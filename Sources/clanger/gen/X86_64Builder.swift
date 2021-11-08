/// Emits X86_64 Assembly according to the AT&T syntax.
final class X86_64Builder {
  init(_ out: OutputHandler) {
    self.out = out
  }

  // MARK: - Private
  private let out: OutputHandler
  private func emit(_ str: String) {
    out.emit(str + "\n")
  }
  private func indent(_ str: String) {
    emit("  \(str)")
  }
}

extension X86_64Builder {
  func global(_ name: String) { emit(".globl _\(name)") }
  func label(_ name: String) { emit("_\(name):") }

  func ret() { indent("ret") }

  func neg(_ reg: X86_64.Reg) { indent("neg  %\(reg)") }
  func not(_ reg: X86_64.Reg) { indent("not  %\(reg)") }

  /// Sets the register to its operand
  func movl(_ val: Int32, _ reg: X86_64.Reg) {
    indent("movl  $\(val), %\(reg)")
  }

  /// cmpl(a,b) computes (b - a) and sets the EFLAGS register accordingly
  func cmpl(_ val: Int32, _ reg: X86_64.Reg) {
    indent("cmpl  $\(val), %\(reg)")
  }

  /// Sets its operand to 1 if the zero-flag of the EFLAGS register (ZF) is on,
  /// and 0 if ZF is off. Note that sete can only set a byte, not a word.
  func sete(_ reg: X86_64.Reg) {
    indent("sete  %\(reg)")
  }
}
