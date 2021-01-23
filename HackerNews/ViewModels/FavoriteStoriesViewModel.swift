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

    func viewDidLoad() {
        load()
    }

    func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.load()
        }
    }

    func lastCellWillDisplay() { }

    private func load(needRefreshIds refreshIDs: Bool = false) {
        api.stories(for: favoritesStore.favorites) { [weak self] (stories) in
            guard let strongSelf = self else { return }
            strongSelf.stories = stories
        }
    }

}

extension FavoriteStoriesViewModel: FavoriteStoreObserver {
    
    func favoriteStoreUpdated(_ store: FavoritesStore) {
        load()
    }
    
}
