//
//  HomeViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 8/27/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import UIKit
import HNBUI

class HomeViewController: TabBarController {

    private let storyStore: StoryStore
    private let favoritesStore: FavoritesStore
    private let storyImageInfoStore: StoryImageInfoStore
    private let api: APIClient

    init(storyStore: StoryStore, favoritesStore: FavoritesStore, storyImageInfoStore: StoryImageInfoStore, api: APIClient) {
        self.storyStore = storyStore
        self.favoritesStore = favoritesStore
        self.storyImageInfoStore = storyImageInfoStore
        self.api = api
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let topStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .top,
                storyStore: storyStore,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore),
            tabBarItemTitle: "top")

        let askStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .ask,
                storyStore: storyStore,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore),
            tabBarItemTitle: "ask")

        let showStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .show,
                storyStore: storyStore,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore),
            tabBarItemTitle: "show")

        let searchStoriesViewController = SearchViewController(
            viewModel: SearchViewModel(
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "search")

        let favoritesStoriesViewController = StoriesViewController(
            viewModel: FavoriteStoriesViewModel(
                favoritesStore: favoritesStore),
            tabBarItemTitle: "favorites")
        
        viewControllers = [
            topStoriesViewController,
            askStoriesViewController,
            showStoriesViewController,
            searchStoriesViewController,
            favoritesStoriesViewController
        ]
        
    }
    



}
