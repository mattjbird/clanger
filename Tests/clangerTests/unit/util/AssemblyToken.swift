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

  internal enum AssemblyKeyword: String {
    case movl
    case movq
    case ret
    case neg
    case not
    case cmpq
    case sete

    case pushq
    case popq

    case addq
    case addl
    case imul
    case subl
    case idivl
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