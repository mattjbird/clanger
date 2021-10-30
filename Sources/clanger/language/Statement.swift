/// Warning: incomplete
public enum Statement: Equatable {
  case `return`(Expression)
}

// MARK: Statement+PrettyPrintable
extension Statement: PrettyPrintable {
  public func pretty() -> String {
    switch self {
        case .return(let expression):
          return "RETURN \(expression.pretty())"
    }
  }
}