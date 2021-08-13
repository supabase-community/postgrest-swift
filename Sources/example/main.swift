import PostgREST
import Foundation

let supabaseUrl = ""
let supabaseKey = ""

var database: PostgrestClient = PostgrestClient.init(url: "\(supabaseUrl)/rest/v1", headers: ["apikey": supabaseKey], schema: "public")

let semaphore = DispatchSemaphore(value: 0)

struct Todo: Codable {
    var `id`: Int?
    var task: String?
    var completed: Bool?
}

database.from("todo").select().execute { (result) in
    switch result {
    case .success(let response):
        guard let data = response.body as? Data else {
            return
        }
        do {
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            print(todos)
        } catch {
            print(error.localizedDescription)
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}

do {
    let todo = Todo(task: "fix some issues in postgrest-swift", completed: true)
    let jsonData: Data = try JSONEncoder().encode(todo)
    
    database.from("todo").insert(values: jsonData).execute { (result) in
        switch result {
        case .success(let response):
            guard let data = response.body as? Data else {
                return
            }
            do {
                let todos = try JSONDecoder().decode([Todo].self, from: data)
                print(todos)
            } catch {
                print(error.localizedDescription)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
}catch {
    print(error.localizedDescription)
}

semaphore.wait()
