import SwiftUI

nonisolated public struct Pokemon: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let sprites: Sprites
    public let flavorText: String
    
    public struct Sprites: Codable, Hashable, Sendable {
        public let front_default: URL
    }    
}
