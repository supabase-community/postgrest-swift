import Foundation

public struct PostgrestResponse: Hashable {
    public let data: Data
    public let status: Int
    public let count: Int?

    public init(data: Data, status: Int, count: Int?) {
        self.data = data
        self.status = status
        self.count = count
    }
}
