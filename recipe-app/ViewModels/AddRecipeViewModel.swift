import Foundation
import UIKit
// Import Recipe and RecipeType

class AddRecipeViewModel {
    var title: String = ""
    var selectedType: RecipeType?
    var image: UIImage?
    var ingredients: [String] = []
    var steps: [String] = []
    var recipeTypes: [RecipeType] = []

    init() {
        recipeTypes = DataManager.shared.loadRecipeTypes()
        selectedType = recipeTypes.first
    }

    func setIngredients(from text: String) {
        ingredients = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    func setSteps(from text: String) {
        steps = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    func ingredientsText() -> String {
        ingredients.joined(separator: ", ")
    }
    func stepsText() -> String {
        steps.joined(separator: "\n")
    }
    func createRecipe() -> Recipe? {
        guard let type = selectedType, !title.isEmpty else { return nil }
        let imageData = image?.jpegData(compressionQuality: 0.8)
        return Recipe(
            id: UUID().uuidString,
            title: title,
            type: type,
            imageData: imageData,
            ingredients: ingredients,
            steps: steps
        )
    }
}
