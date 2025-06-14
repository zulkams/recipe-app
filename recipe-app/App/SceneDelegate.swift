//
//  SceneDelegate.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let mainVC = ViewController()
        let navVC = UINavigationController(rootViewController: mainVC)
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        self.window = window
    }
}
