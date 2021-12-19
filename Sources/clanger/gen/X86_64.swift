/// Various constants that form part of the X86_64 assembly language.
public enum X86_64 {

  /// Register
  public enum Reg: String {
    case rax   // volatile general-purpose (return value / accumulator)
    case al    // least-significant byte of rax
  }

}
