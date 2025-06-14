import Foundation

class RecipeListViewModel {
    let allType = RecipeType(id: "all", name: "All")
    private(set) var recipeTypes: [RecipeType] = []
    private(set) var recipes: [Recipe] = []
    private(set) var filteredRecipes: [Recipe] = []
    var selectedType: RecipeType? = nil {
        didSet { filterRecipes() }
    }

    var onDataChanged: (() -> Void)?

    init() {
        loadData()
    }

    func loadData() {
        recipeTypes = [allType] + DataManager.shared.loadRecipeTypes()
        if selectedType == nil {
            selectedType = allType
        }
        recipes = DataManager.shared.loadRecipes()
        filterRecipes()
        onDataChanged?()
    }

    func filterRecipes() {
        if let type = selectedType, type.id != allType.id {
            filteredRecipes = recipes.filter { $0.type.id == type.id }
        } else {
            filteredRecipes = recipes
        }
        onDataChanged?()
    }

    func addRecipe(_ recipe: Recipe) {
        DataManager.shared.addRecipe(recipe)
        loadData()
    }

    func updateRecipe(_ recipe: Recipe) {
        DataManager.shared.updateRecipe(recipe)
        loadData()
    }

    func deleteRecipe(_ recipe: Recipe) {
        DataManager.shared.deleteRecipe(recipe)
        loadData()
    }

    func recipe(at index: Int) -> Recipe {
        filteredRecipes[index]
    }

    var numberOfRecipes: Int {
        filteredRecipes.count
    }
    var numberOfTypes: Int {
        recipeTypes.count
    }
    func typeName(at index: Int) -> String {
        recipeTypes[index].name
    }
}
