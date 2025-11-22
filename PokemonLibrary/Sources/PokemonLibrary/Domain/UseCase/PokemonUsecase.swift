
nonisolated public struct PokemonUsecase<RepositoryObj: PokemonRepositoryProtocol & Sendable, FavoritePokemonIDDataSourceObj: FavoritePokemonIDDataSourceProtocol>: PokemonUsecaseProtocol & Sendable {
    private let repository: RepositoryObj
    private let favoritePokemonIDDataSource: FavoritePokemonIDDataSourceObj
    
    public init(repository: RepositoryObj = PokemonRepository(), favoritePokemonIDDataSource: FavoritePokemonIDDataSourceObj = FavoritePokemonIDLocalDataSource.shared) {
        self.repository = repository
        self.favoritePokemonIDDataSource = favoritePokemonIDDataSource
    }
    
    @concurrent
    public func fetch(id: Int) async throws -> Pokemon {
        try await repository.fetch(id: id)
    }
    
    @concurrent
    public func fetch(name: String) async throws -> Pokemon {
        try await repository.fetch(name: name)
    }
    
    @concurrent
    public func fetchAll() async throws -> [Pokemon] {
        try await repository.fetchAll()
    }
    
    @concurrent
    public var favoritePokemonIds: [Int] {
        get async {
            await favoritePokemonIDDataSource.favoritePokemonIds
        }
    }
    
    @concurrent
    public func isFavorite(id: Int) async -> Bool {
        await favoritePokemonIDDataSource.isFavorite(id: id)
    }
    
    @concurrent
    public func addFavorite(id: Int) async {
        await favoritePokemonIDDataSource.add(id: id)
    }
    
    @concurrent
    public func removeFavorite(id: Int) async {
        await favoritePokemonIDDataSource.remove(id: id)
    }
    
    @concurrent
    public func clearCache() async {
        await repository.clearCache()
    }
}
