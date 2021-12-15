/// A Token in assembly in the AT&T x86 syntax
internal enum AssemblyToken: Equatable {
  case directive(AssemblyDirective)
  case punctuation(AssemblyPunctuation)
  case keyword(AssemblyKeyword)
  case register(AssemblyRegister)
  case identifier(String)
  case literal(String)


  // TODO: we don't want to treat this punctuation as a token per se, but
  // instead require that e.g., registers are prefixed correctly.
  internal enum AssemblyPunctuation: Character {
    case literalPrefix  = "$"
    case registerPrefix = "%"
    case comma          = ","
    case colon          = ":"
  }

  internal enum AssemblyDirective: String {
    case globl = ".globl"
  }

  internal enum AssemblyKeyword: String {
    case movl
    case ret
    case neg
    case not
    case cmpl
    case sete

    case push
    case pop

    case addl
    case imul
    case subl
    case idivl
  }

  internal enum AssemblyRegister: String {
    case eax
    case al
    case ecx
  }
}

// MARK: Static AssemblyToken
extension AssemblyToken {
  static func fromString(_ str: String) -> AssemblyToken? {
    if str.count == 1,
      let punctuation = AssemblyToken.AssemblyPunctuation(rawValue: str.first!) {
      return .punctuation(punctuation)
    }
    if let directive = AssemblyToken.AssemblyDirective(rawValue: str) {
      return .directive(directive)
    }
    if let keyword = AssemblyToken.AssemblyKeyword(rawValue: str) {
      return .keyword(keyword)
    }
    if let register = AssemblyToken.AssemblyRegister(rawValue: str) {
      return .register(register)
    }
    if str.convertsToIntegerLiteral {
      return .literal(str)
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