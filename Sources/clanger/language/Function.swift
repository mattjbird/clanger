/** Represents a C function.

  Warning: incomplete in at least the following ways:
    * doesn't support a return type
    * doesn't support parameters
    * doesn't support multiple statements
*/
public struct Function: Equatable {
  let name: String
  let body: Statement

  public init(_ name: String, _ body: Statement) {
    self.name = name
    self.body = body
  }
}

// MARK: Function+PrettyPrintable
extension Function: PrettyPrintable {
  public func pretty() -> String {
    return """
      FUNC INT \(self.name):
        params: ()
        body:
          \(self.body.pretty())
    """
  }
}