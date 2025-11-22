import Foundation

public actor PokemonCacheDataSource: PokemonCacheDataSourceProtocol {
    public static let shared = PokemonCacheDataSource()

    private let fileManager: FileManager
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let baseDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        self.directoryURL = baseDirectory.appendingPathComponent("pokemon-cache", isDirectory: true)
    }

    public func fetch(id: Int) -> Pokemon? {
        let url = fileURL(for: id)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(Pokemon.self, from: data)
    }

    public func fetch(name: String) -> Pokemon? {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
            return nil
        }

        let lowercasedName = name.lowercased()

        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            if let data = try? Data(contentsOf: fileURL),
               let pokemon = try? decoder.decode(Pokemon.self, from: data),
               pokemon.name.lowercased() == lowercasedName {
                return pokemon
            }
        }
        return nil
    }

    public func store(_ pokemon: Pokemon) {
        createDirectoryIfNeeded()
        guard let data = try? encoder.encode(pokemon) else { return }
        let url = fileURL(for: pokemon.id)
        try? data.write(to: url, options: .atomic)
    }

    public func clear() {
        try? fileManager.removeItem(at: directoryURL)
        createDirectoryIfNeeded()
    }

    private func fileURL(for id: Int) -> URL {
        directoryURL.appendingPathComponent("\(id).json")
    }

    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
}
