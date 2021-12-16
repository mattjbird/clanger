/// Various constants that form part of the X86_64 assembly language.
public enum X86_64 {

  /// Register
  public enum Reg: String {
    case eax   // volatile general-purpose (return value)
    case al    // least-significant byte of eax
    case ecx   // volatile general-purpose
  }

}
