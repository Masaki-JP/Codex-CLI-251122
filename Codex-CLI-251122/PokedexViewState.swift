import PokemonLibrary

enum PokedexViewState {
    case initial
    case fetching(Task<Void, Never>)
    case fetched(displayedPokemons: [Pokemon], allPokemons: [Pokemon], favoritePokemonIds: [Int], favoriteUpdateTasks: Set<Task<Void, Never>> = [])
    case fetchFailed(any Error) // or ErrorMessage
}
