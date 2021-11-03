import Foundation
import Logging

main( Array(CommandLine.arguments.dropFirst()) )

private func main(_ args: [String]) {
  // Use stderr instead of stdout for logging.
  LoggingSystem.bootstrap(StreamLogHandler.standardError)

  // Compile all the files we're passed.
  // TODO: add a usage statement / help
  guard args.count > 0 else {
    logger.error("No C files to compile. Exiting")
    return
  }

  for path in args {
    logger.info("Compiling \(path)")
    Compiler().compile(path)
  }
}
