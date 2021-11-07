/// A Token in assembly in the AT&T x86 syntax
internal enum AssemblyToken: Equatable {
  case directive(AssemblyDirective)
  case puncutation(AssemblyPunctuation)
  case keyword(AssemblyKeyword)
  case register(AssemblyRegister)
  case identifier(String)
  case literal(String)

  case punctuation(AssemblyPunctuation)

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
    case movl = "movl"
    case ret  = "ret"
    case neg  = "neg"
    case not  = "not"
  }

  internal enum AssemblyRegister: String {
    case eax = "eax"
  }
}

// MARK: Static AssemblyToken
extension AssemblyToken {
  static func fromString(_ str: String) -> AssemblyToken? {
    if str.count == 1,
      let punctuation = AssemblyToken.AssemblyPunctuation(rawValue: str.first!) {
      return .puncutation(punctuation)
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