//
//  MainTabBarViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/7/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let storyStore = StoryStore()
    private let favoritesStore = FavoritesStore()
    private let storyImageInfoStore = StoryImageInfoStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            navigationController(navigationBarTitle: "Top Stories",
                                 tabBarItemTitle: "Top",
                                 tabBarIcon: UIImage(systemName: "list.number"),
                                 viewModel: StoriesViewModel(storyQueryType: .top,
                                                             storyStore: storyStore,
                                                             storyImageInfoStore: storyImageInfoStore,
                                                             favoritesStore: favoritesStore)),
            navigationController(navigationBarTitle: "Ask HN",
                                 tabBarItemTitle: "Ask",
                                 tabBarIcon: UIImage(systemName: "questionmark"),
                                 viewModel: StoriesViewModel(storyQueryType: .ask,
                                                             storyStore: storyStore,
                                                             storyImageInfoStore: storyImageInfoStore,
                                                             favoritesStore: favoritesStore)),
            navigationController(navigationBarTitle: "Show HN",
                                 tabBarItemTitle: "Show",
                                 tabBarIcon: UIImage(systemName: "globe"),
                                 viewModel: StoriesViewModel(storyQueryType: .show,
                                                             storyStore: storyStore,
                                                             storyImageInfoStore: storyImageInfoStore,
                                                             favoritesStore: favoritesStore)),
            searchNavigationController(navigationBarTitle: "Search"),
            navigationController(navigationBarTitle: "Favorites",
                                 tabBarItemTitle: "Favorite",
                                 tabBarIcon: UIImage(systemName: "star"),
                                 viewModel: FavoriteStoriesViewModel(favoritesStore: favoritesStore))
        ]
        
    }
    
    private func navigationController(navigationBarTitle: String, tabBarItemTitle: String, tabBarIcon: UIImage?, viewModel: StoriesViewModelType) -> UINavigationController {
        let storiesViewController = StoriesViewController(viewModel: viewModel, title: navigationBarTitle)
        let navigationController = UINavigationController(rootViewController: storiesViewController)
        navigationController.tabBarItem.title = tabBarItemTitle
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.image = tabBarIcon
        return navigationController
    }
    
    private func searchNavigationController(navigationBarTitle: String) -> UINavigationController {
        let searchViewController = SearchViewController(viewModel: SearchViewModel(favoritesStore: favoritesStore), title: navigationBarTitle)
        let navigationController = UINavigationController(rootViewController: searchViewController)
        navigationController.tabBarItem.title = "Search"
        navigationController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

}
