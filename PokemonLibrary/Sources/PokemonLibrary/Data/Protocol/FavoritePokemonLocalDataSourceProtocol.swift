
public protocol FavoritePokemonIDDataSourceProtocol: Actor {
    var favoritePokemonIds: [Int] { get }
    func isFavorite(id: Int) -> Bool
    func add(id: Int)
    func remove(id: Int)
}
