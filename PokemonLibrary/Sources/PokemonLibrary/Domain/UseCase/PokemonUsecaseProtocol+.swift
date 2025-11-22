
public extension PokemonUsecaseProtocol where Self == PokemonUsecase<PokemonRepository<PokemonFetcher, PokemonCacheDataSource>, FavoritePokemonIDLocalDataSource> {
    static var `default`: PokemonUsecase<PokemonRepository<PokemonFetcher, PokemonCacheDataSource>, FavoritePokemonIDLocalDataSource> { .init() }
}
