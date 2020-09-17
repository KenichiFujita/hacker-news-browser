//
//  FavoriteStoreTests.swift
//  HackerNewsTests
//
//  Created by Kenichi Fujita on 9/14/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import XCTest
@testable import HackerNews

class FavoritesStoreTests: XCTestCase {

    var expectation = XCTestExpectation()
    let key = "favorites"

    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }

    func testInit() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3, 4, 5], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)
        XCTAssertEqual(favoritesStore.favorites, [1, 2, 3, 4, 5])
    }

    func testAddAndAddObserver() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3, 4, 5], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)
        favoritesStore.addObserver(self)
        favoritesStore.add(storyId: 6)

        wait(for: [expectation], timeout: 0.2)
        checkValueOfFavoritesAndUserDefaults(favoritesStore: favoritesStore,
                                             userDefaults: userDefaults,
                                             [6, 1, 2, 3, 4, 5])
    }

    func testHas() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)

        XCTAssertEqual(favoritesStore.has(story: 1), true)
        XCTAssertEqual(favoritesStore.has(story: 2), true)
        XCTAssertEqual(favoritesStore.has(story: 3), true)
        XCTAssertEqual(favoritesStore.has(story: 4), false)
    }

    func testRemove() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)
        favoritesStore.addObserver(self)

        // Check if 1 is removed
        XCTAssertEqual(favoritesStore.favorites, [1, 2, 3])
        favoritesStore.remove(storyId: 1)
        wait(for: [expectation], timeout: 0.2)
        checkValueOfFavoritesAndUserDefaults(favoritesStore: favoritesStore,
                                             userDefaults: userDefaults,
                                             [2, 3])

        // Check if nothing happens when removing id that
        favoritesStore.remove(storyId: 100)
        checkValueOfFavoritesAndUserDefaults(favoritesStore: favoritesStore,
                                             userDefaults: userDefaults,
                                             [2, 3])
    }

    func testRemoveObserver() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)
        favoritesStore.addObserver(self)

        checkValueOfFavoritesAndUserDefaults(favoritesStore: favoritesStore,
                                             userDefaults: userDefaults,
                                             [1, 2, 3])

        // Check observer removed and favoritesStoreUpdated won't be called.
        expectation.isInverted = true
        favoritesStore.removeObserver(self)
        favoritesStore.add(storyId: 4)
        wait(for: [expectation], timeout: 0.2)
        checkValueOfFavoritesAndUserDefaults(favoritesStore: favoritesStore,
                                             userDefaults: userDefaults,
                                             [4, 1, 2, 3])
    }

    func checkValueOfFavoritesAndUserDefaults(favoritesStore: FavoritesStore,
                                              userDefaults: UserDefaults,
                                              _ value: [Int]) {
        XCTAssertEqual(favoritesStore.favorites, value)
        XCTAssertEqual(userDefaults.array(forKey: key) as! [Int], value)
    }

}

extension FavoritesStoreTests: FavoriteStoreObserver {
    func favoriteStoreUpdated(_ store: FavoritesStore) {
        expectation.fulfill()
    }
}
