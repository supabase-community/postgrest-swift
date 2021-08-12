import Foundation

public struct PostgrestError: Error {
    public var details: String?
    public var hint: String?
    public var code: String?
    public var message: String

    init?(from dictionary: [String: Any]) {
        guard let message = dictionary["message"] as? String else {
            return nil
        }

        self.details = dictionary["details"] as? String
        self.hint = dictionary["hint"] as? String
        self.code = dictionary["code"] as? String
        self.message = message
    }

    init(message: String) {
        self.message = message
    }
}

extension PostgrestError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}
