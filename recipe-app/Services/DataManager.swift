//
//  DataManager.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let recipeTypesFile = "recipetypes.json"
    private let recipesKey = "recipes"

    private init() {}

    // MARK: - Recipe Types
    // Path for writable cache (Documents)
    private var recipeTypesFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(recipeTypesFile)
    }
    // Path for bundled fallback (Resources)
    private var bundledRecipeTypesURL: URL? {
        Bundle.main.url(forResource: "recipetypes", withExtension: "json", subdirectory: "Resources")
    }

    func loadRecipeTypes(completion: @escaping ([RecipeType]) -> Void) {
        RecipeTypeAPI.shared.fetchRecipeTypes { [weak self] types in
            if let self = self, !types.isEmpty {
                // Save to disk if not present
                if !FileManager.default.fileExists(atPath: self.recipeTypesFileURL.path) {
                    self.saveRecipeTypesToDisk(types)
                }
                completion(types)
            } else {
                // API failed or empty, try to load from disk
                if let diskTypes = self?.loadRecipeTypesFromDisk(), !diskTypes.isEmpty {
                    completion(diskTypes)
                } else {
                    completion([])
                }
            }
        }
    }

    private func loadRecipeTypesFromDisk() -> [RecipeType]? {
        // Try Documents (writable cache) first
        if FileManager.default.fileExists(atPath: recipeTypesFileURL.path),
           let data = try? Data(contentsOf: recipeTypesFileURL),
           let types = try? JSONDecoder().decode([RecipeType].self, from: data) {
            return types
        }
        // If not present, try bundled Resources
        if let bundledURL = bundledRecipeTypesURL,
           let data = try? Data(contentsOf: bundledURL),
           let types = try? JSONDecoder().decode([RecipeType].self, from: data) {
            return types
        }
        return nil
    }

    private func saveRecipeTypesToDisk(_ types: [RecipeType]) {
        if let data = try? JSONEncoder().encode(types) {
            try? data.write(to: recipeTypesFileURL, options: .atomic)
        }
    }

    // MARK: - Recipes
    func loadRecipes() -> [Recipe] {
        guard let data = UserDefaults.standard.data(forKey: recipesKey) else { return [] }
        let recipes = try? JSONDecoder().decode([Recipe].self, from: data)
        return recipes ?? []
    }

    func saveRecipes(_ recipes: [Recipe]) {
        let data = try? JSONEncoder().encode(recipes)
        UserDefaults.standard.set(data, forKey: recipesKey)
    }

    func addRecipe(_ recipe: Recipe) {
        var recipes = loadRecipes()
        recipes.append(recipe)
        saveRecipes(recipes)
    }

    func updateRecipe(_ recipe: Recipe) {
        var recipes = loadRecipes()
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            saveRecipes(recipes)
        }
    }

    func deleteRecipe(_ recipe: Recipe) {
        var recipes = loadRecipes()
        recipes.removeAll { $0.id == recipe.id }
        saveRecipes(recipes)
    }
    
    func getRecipe(by id: String) -> Recipe? {
        return loadRecipes().first(where: { $0.id == id })
    }
}
