
nonisolated public struct PokemonRepository<FetcherObj: PokemonFetcherProtocol & Sendable, CacheDataSourceObj: PokemonCacheDataSourceProtocol>: PokemonRepositoryProtocol & Sendable {
    private let fetcher: FetcherObj
    private let cache: CacheDataSourceObj
    
    public init(fetcher: FetcherObj = PokemonFetcher(),
         cache: CacheDataSourceObj = PokemonCacheDataSource.shared) {
        self.fetcher = fetcher
        self.cache = cache
    }
    
    public func fetch(id: Int) async throws -> Pokemon {
        if let cached = await cache.fetch(id: id) {
            return cached
        }
        
        let pokemon = try await fetcher.fetch(id: id)
        await cache.store(pokemon)
        return pokemon
    }
    
    public func fetch(name: String) async throws -> Pokemon {
        if let cached = await cache.fetch(name: name) {
            return cached
        }
        
        let pokemon = try await fetcher.fetch(name: name)
        await cache.store(pokemon)
        return pokemon
    }

    public func fetchAll() async throws -> [Pokemon] {
        var cachedPokemons: [Pokemon] = []
        var missingIds: [Int] = []

        for id in 1...151 {
            if let pokemon = await cache.fetch(id: id) {
                cachedPokemons.append(pokemon)
            } else {
                missingIds.append(id)
            }
        }

        if missingIds.isEmpty == true {
            return cachedPokemons.sorted { $0.id < $1.id }
        }

        let fetchedPokemons = try await withThrowingTaskGroup { group in
            missingIds.forEach { id in
                group.addTask {
                    let pokemon = try await fetcher.fetch(id: id)
                    Task.detached { await cache.store(pokemon) }
                    return pokemon
                }
            }
            
            return try await group.reduce(into: [Pokemon]()) { partialResult, pokemon in
                partialResult.append(pokemon)
            }
        }
                        
        return (cachedPokemons + fetchedPokemons).sorted { $0.id < $1.id }
    }
    
    public func clearCache() async {
        await cache.clear()
    }
}
