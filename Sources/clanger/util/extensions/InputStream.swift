import Foundation

// MARK: InputStream(string)
extension InputStream {

    public convenience init(string: String, encoding: String.Encoding = .utf8) {
        self.init(data: string.data(using: encoding)!)
    }

}