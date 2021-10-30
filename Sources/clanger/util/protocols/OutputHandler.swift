/// Handles output, principally to decouple the Generator from its output and
/// allow for easier testing.
public protocol OutputHandler {
  func emit(_ str: String)
}