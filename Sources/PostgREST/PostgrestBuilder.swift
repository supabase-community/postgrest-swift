import Foundation

public class PostgrestBuilder {
    var url: String
    var queryParams: [(name: String, value: String)]
    var headers: [String: String]
    var schema: String?
    var method: String?
    var body: Any?

    init(
        url: String, queryParams: [(name: String, value: String)], headers: [String: String],
        schema: String?, method: String?, body: Any?
    ) {
        self.url = url
        self.queryParams = queryParams
        self.headers = headers
        self.schema = schema
        self.method = method
        self.body = body
    }
    
    /// Executes the built query or command.
    /// - Parameters:
    ///   - head: If `true` use `HEAD` for the HTTP method when building the URLRequest. Defaults to `true`
    ///   - count: A `CountOption` determining how many items to return. Defaults to `nil`
    ///   - completion: Escaping completion handler with either a `PostgrestResponse` or an `Error`. Called after API call is completed and validated.
    public func execute(head: Bool = false, count: CountOption? = nil, completion: @escaping (Result<PostgrestResponse, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try buildURLRequest(head: head, count: count)
        } catch {
            completion(.failure(error))
            return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
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

            do {
                try Self.validate(data: data, response: response)
                let response = try Self.parse(data: data, response: response, request: request)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        })

        dataTask.resume()
    }
    
    /// Validates the response from PostgREST
    /// - Parameters:
    ///   - data: `Data` received from the server.
    ///   - response: `HTTPURLResponse` received from the server.
    /// - Throws: Throws `PostgrestError` if invalid JSON object.
    private static func validate(data: Data, response: HTTPURLResponse) throws {
        if 200 ..< 300 ~= response.statusCode {
            return
        }

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw PostgrestError(message: "failed to get error")
        }

        throw PostgrestError(from: json) ?? PostgrestError(message: "failed to get error")
    }
    
    /// Parses incoming data and server response into a `PostgrestResponse`
    /// - Parameters:
    ///   - data: Data received from the server
    ///   - response: Response received from the server
    /// - Throws: Throws an `Error` if invalid JSON.
    /// - Returns: Returns a `PostgrestResponse`
    private static func parse(data: Data, response: HTTPURLResponse, request: URLRequest) throws -> PostgrestResponse {
        var body: Any = data
        var count: Int?

        if request.httpMethod == "HEAD" {
            if let accept = response.allHeaderFields["Accept"] as? String, accept == "text/csv" {
                body = data
            } else {
                try JSONSerialization.jsonObject(with: data, options: [])
            }
        }

        if let contentRange = response.allHeaderFields["content-range"] as? String,
           let lastElement = contentRange.split(separator: "/").last {
            count = lastElement == "*" ? nil : Int(lastElement)
        }

        let postgrestResponse = PostgrestResponse(body: body)
        postgrestResponse.status = response.statusCode
        postgrestResponse.count = count
        return postgrestResponse
    }
    
    /// Builds the URL request for PostgREST
    /// - Parameters:
    ///   - head: If on, use `HEAD` as the HTTP method.
    ///   - count: A `CountOption`,
    /// - Throws: Throws a `PostgressError`
    /// - Returns: Returns a valid URLRequest for the current query.
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

//        if method == "GET" || method == "HEAD" {
            headers["Content-Type"] = "application/json"
//        }

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
        if let body = body {
            if let httpBody = body as? Data {
                request.httpBody = httpBody
            }else {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }
        }
        return request
    }

    func appendSearchParams(name: String, value: String) {
        queryParams.append((name, value))
    }
}
