class PostgrestResponse {
    var body: Any
    var status: Int?
    var count: Int?
    var error: PostgrestError?

    init(body: Any) {
        self.body = body
    }

    init?(from dictionary: [String: Any]) {
        guard let body = dictionary["body"] else {
            return nil
        }
        self.body = body

        if let status: Int = dictionary["status"] as? Int {
            self.status = status
        }

        if let count: Int = dictionary["count"] as? Int {
            self.count = count
        }

        if let error: [String: Any] = dictionary["error"] as? [String: Any] {
            self.error = PostgrestError(from: error)
        }
    }
}
