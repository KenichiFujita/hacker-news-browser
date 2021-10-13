//
//  MainTabBarViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/7/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let favoritesStore = FavoritesStore()
    private let storyImageInfoStore = StoryImageInfoStore()
    private let api = APIClient()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNavigationController = UINavigationController(
            rootViewController: HomeViewController(
                favoritesStore: favoritesStore,
                storyImageInfoStore: storyImageInfoStore,
                api: api)
        )
        homeNavigationController.tabBarItem.image = UIImage(systemName: "house")

        let loginNavigationController = UINavigationController(
            rootViewController: LoginViewController(
                api: api,
                favoritesStore: favoritesStore
            )
        )
        loginNavigationController.tabBarItem.image = UIImage(systemName: "person")
        
        viewControllers = [
            homeNavigationController,
            loginNavigationController
        ]
        
    }

}
