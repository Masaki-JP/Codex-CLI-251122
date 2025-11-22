import SwiftUI
import PokemonLibrary

struct PokemonDetailView: View {
    private let pokemon: Pokemon
    init(_ pokemon: Pokemon) { self.pokemon = pokemon }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            spriteSection
            flavorTextSection
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { backgroundGradient.ignoresSafeArea() }
        .navigationTitle(pokemon.name.capitalized)
        .preferredColorScheme(.dark)
    }
    
    private var headerSection: some View {
        Text(String(format: "#%03d", pokemon.id))
            .foregroundStyle(.secondary)
            .font(.callout.weight(.semibold))
    }
    
    private var spriteSection: some View {
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
        .frame(height: 240)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.06), in: .rect(cornerRadius: 16))
    }
    
    private var flavorTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pokédex Flavor Text")
                .font(.headline)
            
            Text(pokemon.flavorText)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    PokemonDetailView(.sample)
}
