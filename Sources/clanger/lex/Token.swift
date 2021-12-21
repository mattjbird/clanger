/// The tokens that can appear in a C program
/// - Warning: very much work in progress and incomplete!
public enum CToken: Equatable {
  case keyword(CKeyWord)
  case identifier(String)
  case intLiteral(String)
  case openBrace
  case closeBrace
  case openParen
  case closeParen
  case semiColon
  case hyphen
  case bitwiseComplement
  case bitwiseOr
  case bitwiseAnd
  case addition
  case division
  case asterisk
  case logicalNegation
  case and
  case or
  case equal
  case notEqual
  case lessThan
  case greaterThan
  case lessThanOrEqual
  case greaterThanOrEqual
  case assignment
  // ...
}

// MARK: CToken::CKeyWord
extension CToken {
  /// A keyword from the C language
  public enum CKeyWord: Equatable {
    case int
    case `return`
    // ...
  }
}

// MARK: Static CToken::FromString
extension CToken {
  public static func fromString(_ str: String) -> CToken? {
    // Punctuation
    if let punctuation = CToken.punctuationMatch(str) {
      return punctuation
    }

    // Literals
    if str.convertsToIntegerLiteral {
      return .intLiteral(str)
    }

    // Keywords and identifiers
    switch str {
      case "int":    return .keyword(.int)
      case "return": return .keyword(.return)
      // ...
      default:       return .identifier(str)
    }
  }
}

// MARK: Static CToken::punctuationMatch
extension CToken {
  public static func punctuationMatch(_ str: String) -> CToken? {
    switch str {
      case "{":  return .openBrace
      case "}":  return .closeBrace
      case "(":  return .openParen
      case ")":  return .closeParen
      case ";":  return .semiColon
      case "-":  return .hyphen
      case "~":  return .bitwiseComplement
      case "&":  return .bitwiseAnd
      case "|":  return .bitwiseOr
      case "!":  return .logicalNegation
      case "+":  return .addition
      case "/":  return .division
      case "*":  return .asterisk
      case "&&": return .and
      case "||": return .or
      case "==": return .equal
      case "!=": return .notEqual
      case "<":  return .lessThan
      case ">":  return .greaterThan
      case "<=": return .lessThanOrEqual
      case ">=": return .greaterThanOrEqual
      case "=":  return .assignment
      default:   return nil
    }
  }
}

// MARK: CToken::CustomDebugStringConvertible
extension CToken: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .keyword(let keyword):       return "\(keyword)"
      case .identifier(let identifier): return identifier
      case .intLiteral(let int):        return String(int)
      case .openBrace:                  return "{"
      case .closeBrace:                 return "}"
      case .openParen:                  return "("
      case .closeParen:                 return ")"
      case .semiColon:                  return ";"
      case .hyphen:                     return "-"
      case .bitwiseComplement:          return "~"
      case .bitwiseAnd:                 return "&"
      case .bitwiseOr:                  return "|"
      case .logicalNegation:            return "!"
      case .addition:                   return "+"
      case .division:                   return "/"
      case .asterisk:                   return "*"
      case .and:                        return "&&"
      case .or:                         return "||"
      case .equal:                      return "=="
      case .notEqual:                   return "!="
      case .lessThan:                   return "<"
      case .greaterThan:                return ">"
      case .lessThanOrEqual:            return "<="
      case .greaterThanOrEqual:         return ">="
      case .assignment:                 return "="
    }
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