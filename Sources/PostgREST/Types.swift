import Foundation

public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
public typealias Fetch = (URLRequest, @escaping Completion) -> Void
