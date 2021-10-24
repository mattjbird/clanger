import Foundation

// MARK: InputStream(string)
extension InputStream {
    /** Convenience for initialising an InputStream from a utf8 string. */
    public convenience init(string: String) {
        self.init(data: string.data(using: .utf8)!)
    }

}