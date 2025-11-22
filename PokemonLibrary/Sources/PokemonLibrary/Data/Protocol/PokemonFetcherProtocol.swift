
public protocol PokemonFetcherProtocol {
    func fetch(id: Int) async throws -> Pokemon
    func fetch(name: String) async throws -> Pokemon
    func fetchAll() async throws -> [Pokemon]
}
