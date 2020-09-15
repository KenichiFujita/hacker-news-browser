//
//  FavoriteStoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

class FavoriteStoriesViewModel: StoriesViewModelType {

    var hasMore: Bool = false
    var canShowInstruction: Bool {
        return true
    }
    var favoritesStore: FavoritesStore
    var stories: [Story] = [] {
        didSet {
            delegate?.storiesViewModelUpdated(self)
        }
    }
    weak var delegate: StoriesViewModelDelegate?
    let api: APIClient = APIClient()
    
    init(favoritesStore: FavoritesStore) {
        self.favoritesStore = favoritesStore
        favoritesStore.addObserver(self)
    }

    deinit {
        favoritesStore.removeObserver(self)
    }

    func load() {
        api.stories(for: favoritesStore.favorites) { (stories) in
            self.stories = stories
        }
    }

    func loadNext() { }

}

extension FavoriteStoriesViewModel: FavoriteStoreObserver {
    
    func favoriteStoreUpdated(_ store: FavoritesStore) {
        load()
    }
    
}
