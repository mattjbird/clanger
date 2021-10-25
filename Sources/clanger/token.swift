/** The tokens that can appear in a C program

    Warning: very much work in progress and incomplete.
*/
public enum CToken {
    case openBrace
    case closeBrace
    case openParen
    case closeParen
    case semiColon
    case keyword(CKeyWord)
    case identifier(String)
    case intLiteral(Int)
    // ...

    public enum CKeyWord {
      case int
      case `return`
      // ...
    }
}

// MARK: CToken:Equatable
extension CToken: Equatable {
    public static func ==(lhs: CToken, rhs: CToken) -> Bool {
        switch (lhs, rhs) {
            case (.openBrace, .openBrace):                 return true
            case (.closeBrace, .closeBrace):               return true
            case (.openParen, .closeParen):                return true
            case (.semiColon, .semiColon):                 return true
            case (.keyword(let a), .keyword(let b)):       return a == b
            case (.identifier(let a), .identifier(let b)): return a == b
            case (.intLiteral(let a), .intLiteral(let b)): return a == b
            default:                                       return false
        }
    }
}

// MARK: Static CToken::FromString
extension CToken {
    public static func fromString(_ str: String) -> CToken? {
        switch str {
            case "{":      return .openBrace
            case "}":      return .closeBrace
            case "(":      return .openParen
            case ")":      return .closeParen
            case ";":      return .semiColon

            case "int":    return .keyword(.int)
            case "return": return .keyword(.return)

            default:       return nil
        }
    }
}
