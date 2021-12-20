/// A Token in assembly in the AT&T x86 syntax
internal enum AssemblyToken: Equatable {
  case directive(AssemblyDirective)
  case punctuation(AssemblyPunctuation)
  case keyword(AssemblyKeyword)
  case register(AssemblyRegister)
  case identifier(String)
  case literal(String)


  internal enum AssemblyPunctuation: Character {
    case comma = ","
    case colon = ":"
  }

  internal enum AssemblyDirective: String {
    case globl = ".globl"
  }

  internal enum AssemblyKeyword: String, CaseIterable {
    case addl
    case addq
    case and
    case call
    case cltq
    case cmova
    case cmovae
    case cmovb
    case cmovbe
    case cmove
    case cmovg
    case cmovge
    case cmovl
    case cmovle
    case cmovna
    case cmovnae
    case cmovnb
    case cmovnbe
    case cmovne
    case cmovng
    case cmovnge
    case cmovnl
    case cmovnle
    case cmovns
    case cmovnz
    case cmovs
    case cmovz
    case cmp
    case cmpq
    case cqto
    case cwtl
    case dec
    case idivl
    case idivq
    case imul
    case inc
    case ja
    case jae
    case jb
    case jbe
    case je
    case jg
    case jge
    case jl
    case jle
    case jmp
    case jna
    case jnae
    case jnb
    case jnbe
    case jne
    case jng
    case jnge
    case jnl
    case jnle
    case jns
    case jnz
    case js
    case jz
    case leaq
    case leave
    case movl
    case movq
    case neg
    case not
    case or
    case popq
    case pushq
    case ret
    case sal
    case sar
    case seta
    case setae
    case setb
    case setbe
    case sete
    case setg
    case setge
    case setl
    case setle
    case setna
    case setnae
    case setnb
    case setne
    case setng
    case setnge
    case setnle
    case setns
    case setnz
    case setz
    case shl
    case shr
    case sub
    case subq
    case test
    case xor
  }

  internal enum AssemblyRegister: String {
    case rax
    case rsp
    case rdi
    case rdx
    case rcx
    case r8
    case r9
    case rbx
    case rbp
    case r10
    case r13
    case r14
    case r15
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
    case al
  }
}

// MARK: Static AssemblyToken
extension AssemblyToken {
  static func fromString(_ str: String) -> AssemblyToken? {
    guard !str.isEmpty else { return nil }
    if str.count == 1,
      let punctuation = AssemblyToken.AssemblyPunctuation(rawValue: str.first!) {
      return .punctuation(punctuation)
    }
    switch str.first! {
      case "$":
        let value = String(str.dropFirst())
        guard value.convertsToIntegerLiteral else { return nil }
        return AssemblyToken.literal(value)
      case "%":
        guard let register = AssemblyToken.AssemblyRegister(
          rawValue: String(str.dropFirst())
        ) else {
          return nil
        }
        return .register(register)
      default: break
    }
    if let directive = AssemblyToken.AssemblyDirective(rawValue: str) {
      return .directive(directive)
    }
    if let keyword = AssemblyToken.AssemblyKeyword(rawValue: str) {
      return .keyword(keyword)
    }
    return .identifier(str)
  }
}

// MARK: Fileprivate
fileprivate extension String {
  var convertsToIntegerLiteral: Bool {
    let isHex = self.hasPrefix("0x")
    for (i, c) in self.enumerated() {
      if c.isASCII && (c.isNumber || (isHex && c.isHexDigit)) {
        continue
      }
      if isHex && (i == 0 || i == 1) { continue }
      return false
    }
    return true
  }
}