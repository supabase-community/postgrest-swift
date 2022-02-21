/// Enum of options representing the ways PostgREST can return values from the server.
/// Options are:
/// - minimal => Returns nothing from the server
/// - representation => Returns a copy of the updated data.
///
/// https://postgrest.org/en/v9.0/api.html?highlight=PREFER#insertions-updates
public enum PostgrestReturningOptions: String {
  case minimal = "minimal"
  case representation = "representation"
}
