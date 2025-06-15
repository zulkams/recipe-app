//
//  RecipeListViewModel.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

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
        // Use async loadData in controller after init
    }

    func loadData(completion: (() -> Void)? = nil) {
        RecipeTypeAPI.shared.fetchRecipeTypes { [weak self] types in
            guard let self = self else { return }
            self.recipeTypes = [self.allType] + types
            if self.selectedType == nil {
                self.selectedType = self.allType
            }
            self.recipes = DataManager.shared.loadRecipes()
            self.filterRecipes()
            self.onDataChanged?()
            completion?()
        }
    }

    func filterRecipes() {
        if let selectedType = selectedType, selectedType.id != allType.id {
            filteredRecipes = recipes.filter { $0.type.id == selectedType.id }
        } else {
            filteredRecipes = recipes
        }
        onDataChanged?()
    }
    
    func filterRecipes(with keyword: String?) {
        if let keyword = keyword, !keyword.isEmpty {
            filteredRecipes = recipes.filter { $0.title.localizedCaseInsensitiveContains(keyword) }
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
