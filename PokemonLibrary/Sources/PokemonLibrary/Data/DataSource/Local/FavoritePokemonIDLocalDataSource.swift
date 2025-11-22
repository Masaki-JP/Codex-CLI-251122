import Foundation

public actor FavoritePokemonIDLocalDataSource: FavoritePokemonIDDataSourceProtocol {
    public static let shared = FavoritePokemonIDLocalDataSource()
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "favorite_pokemon_ids"
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public var favoritePokemonIds: [Int] {
        userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
    }
    
    public func isFavorite(id: Int) -> Bool {
        favoritePokemonIds.contains(id)
    }
    
    public func add(id: Int) {
        var ids = favoritePokemonIds
        guard !ids.contains(id) else { return }
        ids.append(id)
        save(ids)
    }
    
    public func remove(id: Int) {
        var ids = favoritePokemonIds
        guard let index = ids.firstIndex(of: id) else { return }
        ids.remove(at: index)
        save(ids)
    }
    
    private func save(_ ids: [Int]) {
        userDefaults.set(ids, forKey: favoritesKey)
    }
}
