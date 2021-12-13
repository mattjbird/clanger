extension Program: PrettyPrintable {
  public func pretty() -> String {
    return function.pretty()
  }
}

extension Function: PrettyPrintable {
  public func pretty() -> String {
    return """
      FUNC INT \(name):
        params: ()
        body:
          \(body.pretty())
    """
  }
}

extension Statement: PrettyPrintable {
  public func pretty() -> String {
    switch self {
        case .return(let expression):
          return "RETURN \(expression.pretty())"
    }
  }
}

extension Expression: PrettyPrintable {
  public func pretty() -> String {
    switch self {
      case .integerConstant(let value):
        return "Int<\(value)>"
      case .unaryOp(let op, let expression):
        return "UnaryOp<\(op),\(expression.pretty())>"
      case .binaryOp(let op, let expr1, let expr2):
        return "BinaryOp<\(op),\(expr1.pretty()),\(expr2.pretty())>"
    }
  }
}
