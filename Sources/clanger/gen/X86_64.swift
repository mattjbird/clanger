/// Various constants that form part of the X86_64 assembly language.
public enum X86_64 {

  /// Register
  public enum Reg: String {
    // Register   Purpose (C convention / idiom)
    case rax   // volatile general-purpose (return value / accumulator)
    case rsp   // stack pointer
    case rdi   // general-purpose (first arg of function)
    case rdx   // " " (third arg)
    case rcx   // " " (fourth arg)
    case r8    // " " (fifth arg)
    case r9    // " " (fifth arg)
    case rbx   // callee-saved
    case rbp   // " "
    case r10   // " "
    case r13   // " "
    case r14   // " "
    case r15   // " "

    // Sub-registers
    // Each of the following are the lower 32 bits of the corrsponding "r" above
    case eax
    case esp
    case edi
    case edx
    case ecx
    case e8
    case e9
    case ebx
    case ebp
    case e10
    case e13
    case e14
    case e15

    case al    // least-significant byte of rax
  }

}
