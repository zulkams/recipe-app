import Foundation

class DataManager {
    static let shared = DataManager()
    private let recipeTypesFile = "recipetypes.json"
    private let recipesKey = "recipes"

    private init() {}

    // MARK: - Recipe Types
    func loadRecipeTypes() -> [RecipeType] {
        guard let url = Bundle.main.url(forResource: "recipetypes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let types = try? JSONDecoder().decode([RecipeType].self, from: data)
        return types ?? []
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
}
