/// Represents a C program.
public struct Program: Equatable {
  let function: Function

  public init(_ function: Function) {
    self.function = function
  }
}

/// Represents a C function.
public struct Function: Equatable {
  let name: String
  let body: Statement

  public init(_ name: String, _ body: Statement) {
    self.name = name
    self.body = body
  }
}

/// Represents a C statement.
public enum Statement: Equatable {
  case `return`(Expression)
}

/// Represents a C expression
public enum Expression: Equatable {
  case integerConstant(Int32)
  indirect case unaryOp(UnaryOperator, Expression)
  indirect case binaryOp(BinaryOperator, Expression, Expression)
}
extension Expression {
  public enum UnaryOperator: Character {
    case negation           = "-"
    case bitwiseComplement  = "~"
    case logicalNegation    = "!"
  }
  public enum BinaryOperator: String {
    case minus              = "-"
    case add                = "+"
    case multiply           = "*"
    case divide             = "/"
    case equal              = "=="
    case notEqual           = "!="
    case and                = "&&"
    case or                 = "||"
    case lessThan           = "<"
    case greaterThan        = ">"
    case lessThanOrEqual    = "<="
    case greaterThanOrEqual = ">="
  }
}
