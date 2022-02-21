import Foundation
import PostgREST

let supabaseUrl = ""
let supabaseKey = ""

var database = PostgrestClient(
  url: "\(supabaseUrl)/rest/v1", headers: ["apikey": supabaseKey], schema: "public")

let semaphore = DispatchSemaphore(value: 0)

struct Todo: Codable {
  var id: Int?
  var task: String?
  var completed: Bool?
}

database.from("todo").select().execute { result in
  switch result {
  case let .success(response):
    do {
      let todos = try response.decoded(to: [Todo].self)
      print(todos)
    } catch {
      print(error.localizedDescription)
    }
  case let .failure(error):
    print(error.localizedDescription)
  }
}

do {
  let todo = Todo(task: "fix some issues in postgrest-swift", completed: true)
  let jsonData: Data = try JSONEncoder().encode(todo)

  database.from("todo").insert(values: jsonData).execute { result in
    switch result {
    case let .success(response):
      do {
        let todos = try response.decoded(to: [Todo].self)
        print(todos)
      } catch {
        print(error.localizedDescription)
      }
    case let .failure(error):
      print(error.localizedDescription)
    }
  }

} catch {
  print(error.localizedDescription)
}

semaphore.wait()
