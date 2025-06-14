import Foundation
import UIKit

class RecipeDetailViewModel {
    private(set) var recipe: Recipe
    var title: String {
        get { recipe.title }
        set { recipe.title = newValue }
    }
    var typeName: String { recipe.type.name }
    var image: UIImage? {
        get {
            guard let data = recipe.imageData else { return nil }
            return UIImage(data: data)
        }
        set {
            recipe.imageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    var ingredients: [String] {
        get { recipe.ingredients }
        set { recipe.ingredients = newValue }
    }
    var steps: [String] {
        get { recipe.steps }
        set { recipe.steps = newValue }
    }
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    func setIngredients(from text: String) {
        recipe.ingredients = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    func setSteps(from text: String) {
        recipe.steps = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    func ingredientsText() -> String {
        recipe.ingredients.joined(separator: ", ")
    }
    func stepsText() -> String {
        recipe.steps.joined(separator: "\n")
    }
    func updateRecipe() {
        DataManager.shared.updateRecipe(recipe)
    }
    func deleteRecipe() {
        DataManager.shared.deleteRecipe(recipe)
    }
}
