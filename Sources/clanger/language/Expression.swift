/// Warning: incomplete
public enum Expression: Equatable {
  case integerConstant(Int32)
  indirect case unaryOp(Operator, Expression)
}

// MARK: Expression:Operator
extension Expression {
  public enum Operator: Character {
    case negation           = "-"
    case bitwiseComplement  = "~"
    case logicalNegation    = "!"
  }
}

// MARK: Expression+PrettyPrintable
extension Expression: PrettyPrintable {
  public func pretty() -> String {
    switch self {
      case .integerConstant(let value):
        return "Int<\(value)>"
      case .unaryOp(let op, let expression):
        return "UnaryOp<\(op),\(expression.pretty())>"
    }
  }
}