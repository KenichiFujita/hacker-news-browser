//
//  FavoritesStore.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/25/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation

protocol FavoriteStoreObserver: AnyObject {
    func favoriteStoreUpdated(_ store: FavoritesStore)
}

class FavoritesStore {
    var ids: [Int] = []
    let key = "favorites"
    let userDefaults: UserDefaults
    weak var observer: FavoriteStoreObserver?
      
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        self.ids = userDefaults.array(forKey: key) as? [Int] ?? []
    }
    
    var favorites: [Int] {
        return ids
    }
    
    func add(storyId: Int) {
        self.ids.insert(storyId, at: 0)
        observer?.favoriteStoreUpdated(self)
        save()
    }
    
    func remove(storyId: Int) {
        guard let index = self.ids.firstIndex(of: storyId) else {
            return
        }
        self.ids.remove(at: index)
        observer?.favoriteStoreUpdated(self)
        save()
    }
    
    func has(story: Int) -> Bool {
        return self.ids.contains(story)
    }
    
    private func save() {
        userDefaults.set(self.ids, forKey: key)
    }
    
}
