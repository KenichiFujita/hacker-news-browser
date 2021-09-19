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

    private let favoritesStore: FavoritesStore
    private let storyImageInfoStore: StoryImageInfoStore
    private let api: APIClient

    init(favoritesStore: FavoritesStore, storyImageInfoStore: StoryImageInfoStore, api: APIClient) {
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
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "top")

        let newStoriesViewController = StoriesViewController(
            viewModel: ChronologicalStoriesViewModel(
                storyQueryType: .new,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "new")

        let askStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .ask,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "ask")

        let showStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .show,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "show")

        let jobStoriesViewController = StoriesViewController(
            viewModel: ChronologicalStoriesViewModel(
                storyQueryType: .job,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "job")

        let bestStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .best,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "best")

        let activeStoriesViewController = StoriesViewController(
            viewModel: StoriesViewModel(
                storyQueryType: .active,
                storyImageInfoStore: storyImageInfoStore,
                favoritesStore: favoritesStore,
                api: api),
            tabBarItemTitle: "active")
        
        viewControllers = [
            topStoriesViewController,
            newStoriesViewController,
            askStoriesViewController,
            showStoriesViewController,
            jobStoriesViewController,
            bestStoriesViewController,
            activeStoriesViewController
        ]
        
    }
    



}
