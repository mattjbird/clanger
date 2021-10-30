/// Warning: incomplete
public enum Expression: Equatable {
  case integerConstant(Int32)
}

// MARK: Expression+PrettyPrintable
extension Expression: PrettyPrintable {
  public func pretty() -> String {
    switch self {
      case .integerConstant(let value):
        return "Int<\(value)>"
    }
  }
}