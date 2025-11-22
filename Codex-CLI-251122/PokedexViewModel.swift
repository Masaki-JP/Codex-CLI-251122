import Foundation
import PokemonLibrary

@Observable
final class PokedexViewModel<PokemonUsecaseObj: PokemonUsecaseProtocol> {
    private let pokemonUsecase: PokemonUsecaseObj
    private(set) var state: PokedexViewState = .initial
    
    init(pokemonUsecase: PokemonUsecaseObj = .default) {
        self.pokemonUsecase = pokemonUsecase
    }
    
    isolated deinit {
        if case .fetching(let task) = state {
            task.cancel()
        } else if case .fetched(_, _, _, let tasks) = state {
            tasks.forEach { task in
                task.cancel()
            }
        }
    }
    
    var isShowingSettingsView = false
    
    var searchText = "" {
        didSet {
            guard case .fetched(_, let allPokemons, let favoritePokemonIds, let favoriteUpdateTasks) = state else { return }
            
            let displayedPokemons = displayedPokemons(allPokemons: allPokemons, favoritePokemonIDs: favoritePokemonIds, sortOrder: sortOrder)

            state = .fetched(displayedPokemons: displayedPokemons, allPokemons: allPokemons, favoritePokemonIds: favoritePokemonIds, favoriteUpdateTasks: favoriteUpdateTasks)
        }
    }
    
    var isSortButtonDisabled: Bool {
        if case .fetched = state { false } else { true }
    }
    
    var sortOrder: SortOrder = .forward {
        didSet {
            updateDisplayedPokemonsWhenFetchedState()
        }
    }
    
    var isFilterButtonDisabled: Bool {
        if case .fetched = state { false } else { true }
    }
    
    var isFavoriteFilterd = false {
        didSet {
            updateDisplayedPokemonsWhenFetchedState()
        }
    }
    
    private func updateDisplayedPokemonsWhenFetchedState() {
        guard case .fetched(_, let allPokemons, let favoritePokemonIds, let favoriteUpdateTasks) = state else { return }
        
        let displayedPokemons = displayedPokemons(allPokemons: allPokemons, favoritePokemonIDs: favoritePokemonIds, sortOrder: sortOrder)
        
        state = .fetched(displayedPokemons: displayedPokemons, allPokemons: allPokemons, favoritePokemonIds: favoritePokemonIds, favoriteUpdateTasks: favoriteUpdateTasks)
    }
    
    func onAppear() {
        guard case .initial = state else { return }
        
        let task = Task {
            do {
                async let allPokemons = pokemonUsecase.fetchAll()
                async let favoritePokemonIDs = pokemonUsecase.favoritePokemonIds
                let displayedPokemons = try await displayedPokemons(allPokemons: allPokemons, favoritePokemonIDs: favoritePokemonIDs)
                state = try await .fetched(displayedPokemons: displayedPokemons, allPokemons: allPokemons, favoritePokemonIds: favoritePokemonIDs)
            } catch {
                state = .fetchFailed(error)
            }
        }
        
        guard case .initial = state else { return } // Just in case
        
        state = .fetching(task)
    }
    
    func favoriteButtonAction(id: Int) {
        guard case .fetched = state else { return }
        
        let task = Task {
            if await pokemonUsecase.isFavorite(id: id) == true {
                await pokemonUsecase.removeFavorite(id: id)
            } else {
                await pokemonUsecase.addFavorite(id: id)
            }
            
            guard case .fetched(let displayedPokemons, let allPokemons,  _, let favoriteUpdateTasks) = state else { return }
            
            let ids = await pokemonUsecase.favoritePokemonIds
            
            state = .fetched(displayedPokemons: displayedPokemons, allPokemons: allPokemons, favoritePokemonIds: ids, favoriteUpdateTasks: favoriteUpdateTasks)
        }
        
        guard case .fetched(let displayedPokemons, let allPokemons, let favoritePokemonIds, var favoriteUpdateTasks) = state else { return }
        
        favoriteUpdateTasks.insert(task)
        
        state = .fetched(displayedPokemons: displayedPokemons, allPokemons: allPokemons, favoritePokemonIds: favoritePokemonIds, favoriteUpdateTasks: favoriteUpdateTasks)
    }
    
    func settingsButtonAction() {
        isShowingSettingsView = true
    }
    
    private func displayedPokemons(allPokemons: [Pokemon], favoritePokemonIDs: [Int], sortOrder: SortOrder = .forward) -> [Pokemon] {
        var processedPokemons = isFavoriteFilterd == false ? allPokemons : allPokemons.filter { favoritePokemonIDs.contains($0.id) }
        
        processedPokemons.sort { lhs, rhs in sortOrder == .forward ? lhs.id < rhs.id : lhs.id > rhs.id }
        
        return searchText.isEmpty ? processedPokemons : processedPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
}
