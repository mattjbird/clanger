import Foundation

main( Array(CommandLine.arguments.dropFirst()) )

private func main(_ args: [String]) {
  guard args.count > 0 else {
    print("No C files to compile. Exiting.")
    return
  }

  for path in args {
    print("Compiling \(path)")
    Compiler().compile(path)
  }
}
