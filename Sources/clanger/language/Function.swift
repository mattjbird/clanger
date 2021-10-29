/** Represents a C function.

  Warning: incomplete in the following ways:
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