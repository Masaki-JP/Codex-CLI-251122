import Foundation

nonisolated public struct PokemonFetcher: PokemonFetcherProtocol & Sendable {
    private let session: URLSession
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetch(id: Int) async throws -> Pokemon {
        let url = baseURL.appendingPathComponent("\(id)")
        return try await requestPokemon(url: url)
    }

    public func fetch(name: String) async throws -> Pokemon {
        let url = baseURL.appendingPathComponent(name.lowercased())
        return try await requestPokemon(url: url)
    }

    public func fetchAll() async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for id in 1...151 {
                group.addTask {
                    try await fetch(id: id)
                }
            }

            var results: [Pokemon] = []
            for try await pokemon in group {
                results.append(pokemon)
            }

            return results.sorted { $0.id < $1.id }
        }
    }

    private func requestPokemon(url: URL) async throws -> Pokemon {
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        
        let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)        
        let speciesResponse = try await requestSpecies(url: pokemonResponse.species.url)
        let flavorText = try englishFlavorText(from: speciesResponse.flavor_text_entries)
        
        return Pokemon(
            id: pokemonResponse.id,
            name: pokemonResponse.name,
            sprites: pokemonResponse.sprites,
            flavorText: flavorText
        )
    }
    
    private func requestSpecies(url: URL) async throws -> PokemonSpeciesResponse {
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        
        return try JSONDecoder().decode(PokemonSpeciesResponse.self, from: data)
    }
    
    private func englishFlavorText(from entries: [PokemonSpeciesResponse.FlavorTextEntry]) throws -> String {
        guard let englishEntry = entries.first(where: { $0.language.name?.lowercased() == "en" }),
              case let sanitized = sanitizeFlavorText(englishEntry.flavor_text),
              sanitized.isEmpty == false else {
            throw PokemonFetcherError.missingFlavorText
        }
        
        return sanitized
    }
        
    private func sanitizeFlavorText(_ text: String) -> String {
        text
            .replacing("\n", with: " ")
            .replacing("\u{000c}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private struct PokemonResponse: Decodable {
        let id: Int
        let name: String
        let sprites: Pokemon.Sprites
        let species: NamedAPIResource
    }
    
    private struct PokemonSpeciesResponse: Decodable {
        let flavor_text_entries: [FlavorTextEntry]
        
        struct FlavorTextEntry: Decodable {
            let flavor_text: String
            let language: NamedAPIResource
        }
    }
    
    private struct NamedAPIResource: Decodable {
        let name: String?
        let url: URL
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw PokemonFetcherError.invalidResponse
        }
    }
}
