//
//  MainTabBarViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/7/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit
import HNBUI

class MainTabBarController: TabBarController {

    private let storyStore = StoryStore()
    private let favoritesStore = FavoritesStore()
    private let storyImageInfoStore = StoryImageInfoStore()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .systemBackground
        tabBar.tintColor = .hnbOrange
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topStoriesViewController = StoriesViewController(viewModel: StoriesViewModel(storyQueryType: .top,
                                                                                         storyStore: storyStore,
                                                                                         storyImageInfoStore: storyImageInfoStore,
                                                                                         favoritesStore: favoritesStore),
                                                             tabBarTitle: "Top Stories",
                                                             tabBarImage: UIImage(systemName: "list.number"))
        let askHNViewController = StoriesViewController(viewModel: StoriesViewModel(storyQueryType: .ask,
                                                                                    storyStore: storyStore,
                                                                                    storyImageInfoStore: storyImageInfoStore,
                                                                                    favoritesStore: favoritesStore),
                                                        tabBarTitle: "Ask HN",
                                                        tabBarImage: UIImage(systemName: "questionmark"))
        let showHNViewController = StoriesViewController(viewModel: StoriesViewModel(storyQueryType: .show,
                                                                                     storyStore: storyStore,
                                                                                     storyImageInfoStore: storyImageInfoStore,
                                                                                     favoritesStore: favoritesStore),
                                                         tabBarTitle: "Show HN",
                                                         tabBarImage: UIImage(systemName: "globe"))
        let searchViewController = SearchViewController(viewModel: SearchViewModel(favoritesStore: favoritesStore),
                                                        tabBarTitle: "Search",
                                                        TabBarImage: UIImage(systemName: "magnifyingglass"))
        let favoriteViewController = StoriesViewController(viewModel: FavoriteStoriesViewModel(favoritesStore: favoritesStore),
                                                           tabBarTitle: "Favorites",
                                                           tabBarImage: UIImage(systemName: "star"))

        viewControllers = [
            topStoriesViewController,
            askHNViewController,
            showHNViewController,
            searchViewController,
            favoriteViewController
        ]
    }

}
