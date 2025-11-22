
public protocol PokemonRepositoryProtocol {
    func fetch(id: Int) async throws -> Pokemon
    func fetch(name: String) async throws -> Pokemon
    func fetchAll() async throws -> [Pokemon]
    func clearCache() async
}
