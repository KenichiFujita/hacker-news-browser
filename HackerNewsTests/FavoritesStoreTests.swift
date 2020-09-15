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

    func testAddAndMethodsForObservers() {
        let userDefaults = UserDefaults()
        userDefaults.set([1, 2, 3, 4, 5], forKey: key)
        let favoritesStore = FavoritesStore(userDefaults: userDefaults)
        favoritesStore.addObserver(self)
        favoritesStore.add(storyId: 6)

        wait(for: [expectation], timeout: 0.2)
        XCTAssertEqual(favoritesStore.favorites, [6, 1, 2, 3, 4, 5])
        XCTAssertEqual(userDefaults.array(forKey: key) as! [Int], [6, 1, 2, 3, 4, 5])

        favoritesStore.removeObserver(self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            favoritesStore.add(storyId: 7)
            let userDefaultsArray = userDefaults.array(forKey: self.key) as! [Int]
            XCTAssertEqual(userDefaultsArray.contains(7), false)
        }
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

        favoritesStore.remove(storyId: 1)

        wait(for: [expectation], timeout: 0.2)
        XCTAssertEqual(favoritesStore.favorites, [2, 3])
        XCTAssertEqual(userDefaults.array(forKey: key) as! [Int], [2, 3])

        favoritesStore.remove(storyId: 100)

        XCTAssertEqual(favoritesStore.favorites, [2, 3])
        XCTAssertEqual(userDefaults.array(forKey: key) as! [Int], [2, 3])
    }

}

extension FavoritesStoreTests: FavoriteStoreObserver {
    func favoriteStoreUpdated(_ store: FavoritesStore) {
        expectation.fulfill()
    }
}
