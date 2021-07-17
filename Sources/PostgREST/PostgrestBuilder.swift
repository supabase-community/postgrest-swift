import Foundation

public class PostgrestBuilder {
    var url: String
    var queryParams: [(name: String, value: String)] = []
    var headers: [String: String]
    var schema: String?
    var method: String?
    var body: [String: Any]?

    public init(url: String, headers: [String: String] = [:], schema: String?) {
        self.url = url
        self.headers = headers
        self.schema = schema
    }

    public init(url: String, method: String?, headers: [String: String] = [:], schema: String?, body: [String: Any]?) {
        self.url = url
        self.headers = headers
        self.schema = schema
        self.method = method
        self.body = body
    }

    public func execute(head: Bool = false, count: CountOption? = nil, completion: @escaping (Result<PostgrestResponse, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try buildURLRequest(head: head, count: count)
        } catch {
            completion(.failure(error))
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { [unowned self] (data, response, error) -> Void in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(PostgrestError(message: "failed to get response")))
                return
            }
            
            guard let data = data else {
                completion(.failure(PostgrestError(message: "empty data")))
                return
            }
            
            completion(Result { try self.parse(data: data, response: response)} )
        })

        dataTask.resume()
    }

    private func parse(data: Data, response: HTTPURLResponse) throws -> PostgrestResponse {
        if response.statusCode == 200 || 200 ..< 300 ~= response.statusCode {
            var body: Any = data
            var count: Int?

            if let method = method, method == "HEAD" {
                if let accept = response.allHeaderFields["Accept"] as? String, accept == "text/csv" {
                    body = data
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        body = json
                    } catch {
                        throw error
                    }
                }
            }

            if let contentRange = response.allHeaderFields["content-range"] as? String, let lastElement = contentRange.split(separator: "/").last {
                count = lastElement == "*" ? nil : Int(lastElement)
            }

            let postgrestResponse = PostgrestResponse(body: body)
            postgrestResponse.status = response.statusCode
            postgrestResponse.count = count
            return postgrestResponse
        } else {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let errorJson: [String: Any] = json as? [String: Any] {
                    throw PostgrestError(from: errorJson) ?? PostgrestError(message: "failed to get error")
                } else {
                    throw PostgrestError(message: "failed to get error")
                }
            } catch {
                throw error
            }
        }
    }
    
    func buildURLRequest(head: Bool, count: CountOption?) throws -> URLRequest {
        if head {
            method = "HEAD"
        }

        if let count = count {
            if let prefer = headers["Prefer"] {
                headers["Prefer"] = "\(prefer),count=\(count.rawValue)"
            } else {
                headers["Prefer"] = "count=\(count.rawValue)"
            }
        }

        guard let method = method else {
            throw PostgrestError(message: "Missing table operation: select, insert, update or delete")
        }

        if method == "GET" || method == "HEAD" {
            headers["Content-Type"] = "application/json"
        }

        if let schema = schema {
            if method == "GET" || method == "HEAD" {
                headers["Accept-Profile"] = schema
            } else {
                headers["Content-Profile"] = schema
            }
        }

        guard var components = URLComponents(string: url) else {
            throw PostgrestError(message: "badURL")
        }
        
        if !queryParams.isEmpty {
            components.queryItems = components.queryItems ?? []
            components.queryItems!.append(contentsOf: queryParams.map(URLQueryItem.init))
        }
        
        guard let url = components.url else {
            throw PostgrestError(message: "badURL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        return request
    }

    func appendSearchParams(name: String, value: String) {
        queryParams.append((name, value))
    }
}
