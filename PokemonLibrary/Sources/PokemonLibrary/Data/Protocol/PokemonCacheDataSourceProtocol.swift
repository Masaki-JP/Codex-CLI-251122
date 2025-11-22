
public protocol PokemonCacheDataSourceProtocol: Actor {
    func fetch(id: Int) -> Pokemon?
    func fetch(name: String) -> Pokemon?
    func store(_ pokemon: Pokemon)
    func clear()
}
