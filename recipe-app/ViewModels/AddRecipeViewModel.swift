//
//  AddRecipeViewModel.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

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

    init(recipeTypes: [RecipeType] = []) {
        self.recipeTypes = recipeTypes
        if let first = recipeTypes.first {
            self.selectedType = first
        }
    }

    func loadTypes(completion: @escaping () -> Void) {
        DataManager.shared.loadRecipeTypes { [weak self] types in
            self?.recipeTypes = types
            self?.selectedType = types.first
            completion()
        }
    }

    init() {}

    func setIngredients(from text: String) {
        ingredients = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    func setSteps(from text: String) {
        steps = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
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
    
    func isValid() -> Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !ingredients.isEmpty &&
            !steps.isEmpty &&
            selectedType != nil
    }
}
