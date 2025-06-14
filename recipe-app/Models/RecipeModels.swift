import Foundation

struct RecipeType: Codable, Equatable {
    let id: String
    let name: String
}

struct Recipe: Codable, Equatable {
    var id: String
    var title: String
    var type: RecipeType
    var imageData: Data? // Store image as Data
    var ingredients: [String]
    var steps: [String]
}
