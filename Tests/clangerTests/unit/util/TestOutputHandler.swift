@testable import clanger

/// A String-based output handler for testing
public final class TestOutputHandler: OutputHandler
{
  public private(set) var value = ""

  public func emit(_ str: String) {
    self.value.append(str)
  }
}