
public protocol PokemonUsecaseProtocol: Sendable {
    func fetch(id: Int) async throws -> Pokemon
    func fetch(name: String) async throws -> Pokemon
    func fetchAll() async throws -> [Pokemon]
    var favoritePokemonIds: [Int] { get async }
    func isFavorite(id: Int) async -> Bool
    func addFavorite(id: Int) async
    func removeFavorite(id: Int) async
    func clearCache() async
}
