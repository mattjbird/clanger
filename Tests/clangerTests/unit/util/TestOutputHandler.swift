@testable import clanger

/// A String-based output handler for testing
public final class TestOutputHandler: OutputHandler
{
  public private(set) var value = ""

  public func emit(_ str: String) {
    if self.value.isEmpty {
      self.value = str
    } else {
      self.value.append("\n\(str)")
    }
  }
}