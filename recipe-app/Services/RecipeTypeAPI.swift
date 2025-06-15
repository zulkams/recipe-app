//
//  RecipeTypeAPI.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import Foundation
import Alamofire

class RecipeTypeAPI {
    static let shared = RecipeTypeAPI()
    private let baseURL = "https://zk-backend.onrender.com"

    func fetchRecipeTypes(completion: @escaping ([RecipeType]) -> Void) {
        guard let accessToken = KeychainService.shared.get("accessToken") else {
            completion(RecipeTypeAPI.loadRecipeTypesFallback())
            return
        }
        let url = baseURL + "/recipetypes"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        print("[RecipeTypeAPI] Requesting: \(url)")
        print("[RecipeTypeAPI] Headers: \(headers)")
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseData { response in
                print("[RecipeTypeAPI] Response status: \(response.response?.statusCode ?? -1)")
                switch response.result {
                case .success(let data):
                    if let types = try? JSONDecoder().decode([RecipeType].self, from: data), !types.isEmpty {
                        print("[RecipeTypeAPI] Successfully decoded \(types.count) recipe types from API.")
                        completion(types)
                    } else {
                        print("[RecipeTypeAPI] API returned no types or failed to decode. Falling back to local JSON.")
                        completion(RecipeTypeAPI.loadRecipeTypesFallback())
                    }
                case .failure(let error):
                    print("[RecipeTypeAPI] API request failed: \(error). Falling back to local JSON.")
                    completion(RecipeTypeAPI.loadRecipeTypesFallback())
                }
            }
    }
    private static func loadRecipeTypesFallback() -> [RecipeType] {
        guard let url = Bundle.main.url(forResource: "recipetypes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let types = try? JSONDecoder().decode([RecipeType].self, from: data) else {
            return []
        }
        return types
    }
}
