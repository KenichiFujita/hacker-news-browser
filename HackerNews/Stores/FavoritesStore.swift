//
//  FavoritesStore.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/25/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import Foundation

@objc protocol FavoriteStoreObserver: AnyObject {
    func favoriteStoreUpdated(_ store: FavoritesStore)
}

class FavoritesStore: NSObject {
    private var ids: [Int] = []
    private let key = "favorites"
    private let userDefaults: UserDefaults
    private var observers: NSHashTable = NSHashTable<FavoriteStoreObserver>.weakObjects()
    var favorites: [Int] {
        return ids
    }
      
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        self.ids = userDefaults.array(forKey: key) as? [Int] ?? []
    }
    
    func add(storyId: Int) {
        self.ids.insert(storyId, at: 0)
        observers.allObjects.forEach {
            $0.favoriteStoreUpdated(self)
        }
        save()
    }
    
    func remove(storyId: Int) {
        guard let index = self.ids.firstIndex(of: storyId) else {
            return
        }
        self.ids.remove(at: index)
        observers.allObjects.forEach {
            $0.favoriteStoreUpdated(self)
        }
        save()
    }
    
    func has(story: Int) -> Bool {
        return self.ids.contains(story)
    }
    
    private func save() {
        userDefaults.set(self.ids, forKey: key)
    }

    func addObserver(_ observer: FavoriteStoreObserver) {
        observers.add(observer)
    }

    func removeObserver(_ observer: FavoriteStoreObserver) {
        observers.remove(observer)
    }
    
}
