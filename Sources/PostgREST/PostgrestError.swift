import Foundation

public struct PostgrestError: Error {
    public var details: String?
    public var hint: String?
    public var code: String?
    public var message: String

    init?(from dictionary: [String: Any]) {
        guard let details = dictionary["details"] as? String,
              let hint = dictionary["hint"] as? String,
              let code = dictionary["code"] as? String,
              let message = dictionary["message"] as? String
        else {
            return nil
        }
        self.details = details
        self.hint = hint
        self.code = code
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
