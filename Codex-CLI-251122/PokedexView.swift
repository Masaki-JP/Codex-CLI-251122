import SwiftUI
import PokemonLibrary

struct PokedexView: View {
    @State private var viewModel = PokedexViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial: EmptyView()
                case .fetching: ProgressView("Loading...")
                    
                case .fetched(let displayedPokemons, _, let favoritePokemonIds, _):
                    gridList(displayedPokemons, favoritePokemonIds: favoritePokemonIds)
                        .searchable(text: $viewModel.searchText)
                    
                case .fetchFailed(let error):
                    errorAlert(error)
                }
            }
            .navigationTitle("Pokedex")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { backgroundGradient.ignoresSafeArea() }
            .toolbar { pokedexViewToolbarItems }
            .navigationDestination(isPresented: $viewModel.isShowingSettingsView) {
                Text("SettingsView")
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .preferredColorScheme(.dark)
    }
    
    private func gridList(_ pokemons: [Pokemon], favoritePokemonIds: [Int]) -> some View {
        let spacing: CGFloat = 16
        let gridColumns = [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: spacing)]
        
        return ScrollView {
            LazyVGrid(columns: gridColumns, spacing: spacing) {
                ForEach(pokemons) { pokemon in
                    NavigationLink(value: pokemon) {
                        pokemonCard(pokemon, isFavorite: favoritePokemonIds.contains(pokemon.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(.horizontal, 12, for: .scrollContent)
        .overlay {
            if pokemons.isEmpty == true {
                ContentUnavailableView("No Content", systemImage: "tray", description: Text("The selected condition is Favorite only."))
            }
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(pokemon)
                .toolbar { pokemonDetailViewToolbarItems(pokemon, favoritePokemonIds: favoritePokemonIds) }
        }
    }
    
    private func pokemonCard(_ pokemon: Pokemon, isFavorite: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader(pokemon, isFavorite: isFavorite)
            cardImage(pokemon)
            cardInfoSection(pokemon)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(cardGradient, in: .rect(cornerRadius: 18))
        .compositingGroup()
        .shadow(color: .black.opacity(0.16), radius: 10, x: 8, y: 8)
    }
    
    private func cardHeader(_ pokemon: Pokemon, isFavorite: Bool) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: .zero) {
            Text(String(format: "#%03d", pokemon.id))
                .foregroundStyle(.secondary)
                .font(.callout.weight(.semibold))
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundStyle(.white)
                .font(.caption.bold())
                .padding(6)
                .background(.pink.gradient, in: .circle)
                .shadow(color: .pink.opacity(0.35), radius: 6, x: 4, y: 4)
                .opacity(isFavorite ? 1.0 : 0.0)
        }
    }
    
    private func cardImage(_ pokemon: Pokemon) -> some View {
        AsyncImage(url: pokemon.sprites.front_default) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                
            case .failure:
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(18)
                
            case .empty: ProgressView()
            @unknown default: EmptyView()
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 4))
    }
    
    private func cardInfoSection(_ pokemon: Pokemon) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pokemon.name.capitalized)
                .foregroundStyle(.primary)
                .font(.headline)
            Text(pokemon.flavorText)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
    
    private var cardGradient: LinearGradient {
        let colors: [Color] = [Color(red: 0.18, green: 0.30, blue: 0.52), Color(red: 0.08, green: 0.18, blue: 0.36)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private func errorAlert(_ error: any Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
            Text("Load failed")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private var pokedexViewToolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Orders", selection: $viewModel.sortOrder) {
                    Text("Ascending").tag(SortOrder.forward)
                    Text("Descenging").tag(SortOrder.reverse)
                }
            }
            .disabled(viewModel.isSortButtonDisabled)
            
            Menu("Filter", systemImage: "line.horizontal.3.decrease") {
                Toggle("Favorite", isOn: $viewModel.isFavoriteFilterd)
            }
            .disabled(viewModel.isFilterButtonDisabled)
            
            Button("Settings", systemImage: "gearshape.fill", action: viewModel.settingsButtonAction)
        }
    }
    
    private func pokemonDetailViewToolbarItems(_ pokemon: Pokemon, favoritePokemonIds: [Int]) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Toggle favorite", systemImage: "heart.fill") {
                viewModel.favoriteButtonAction(id: pokemon.id)
            }
            .tint(favoritePokemonIds.contains(pokemon.id) ? .pink : nil)
        }
    }
}

#Preview {
    PokedexView()
}
