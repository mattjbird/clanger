/** Represents a C program.

  Warning: incomplete in at least the following ways:
    * doesn't support multiple functions
    * doesn't support comments
    * doesn't support static data
    * doesn't support struct, enum, or union definitions
*/
public struct Program: Equatable {
  let function: Function

  public init(_ function: Function) {
    self.function = function
  }
}