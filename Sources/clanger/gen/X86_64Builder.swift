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

  func pushq(_ reg: X86_64.Reg) { indent("pushq  %\(reg)") }
  func popq(_ reg: X86_64.Reg) { indent("popq  %\(reg)") }

  func ret() { indent("ret") }

  func neg(_ reg: X86_64.Reg) { indent("neg  %\(reg)") }
  func not(_ reg: X86_64.Reg) { indent("not  %\(reg)") }

  /// Sets the register to its operand.
  func movl(_ val: Int32, _ reg: X86_64.Reg) {
    indent("movl  $\(val), %\(reg)")
  }

  /// Sets `regB` to `regA`
  func movl(_ regA: X86_64.Reg, _ regB: X86_64.Reg) {
    indent("movl  %\(regA), %\(regB)")
  }

  /// cmpl(a,b) computes (b - a) and sets the EFLAGS register accordingly.
  func cmpl(_ val: Int32, _ reg: X86_64.Reg) {
    indent("cmpl  $\(val), %\(reg)")
  }

  /// Sets its operand to 1 if the zero-flag of the EFLAGS register (ZF) is on,
  /// and 0 if ZF is off. Note that sete can only set a byte, not a word.
  func sete(_ reg: X86_64.Reg) {
    indent("sete  %\(reg)")
  }

  /// Computes `regA` + `regB` and saves the result in `regB`.
  func addl(_ regA: X86_64.Reg, _ regB: X86_64.Reg) {
    indent("addl  %\(regA), %\(regB)")
  }

  /// Computes `regA` * `regB` and saves the result in `regB`.
  func imul(_ regA: X86_64.Reg, _ regB: X86_64.Reg) {
    indent("imul  %\(regA), %\(regB)")
  }

  /// Computes `regB` - `rebA` and saves the result in `regB`.
  func subl(_ regA: X86_64.Reg, _ regB: X86_64.Reg) {
    indent("imul  %\(regA), %\(regB)")
  }

  /// Performs a signed divide of %edx:%eax by `reg` putting the quotient in
  /// %eax, and the remainder in %edx.
  func idivl(_ reg: X86_64.Reg) {
    indent("idivl  %reg")
  }

  /// Converts the doubleword in %eax into a quadword in %edx:%eax by sign-
  /// extending %eax into %edx (i.e., each bit of %edx is filled with the most
  /// significant bit of %eax).
  func cdq() {
    indent("cdq")
  }
}
