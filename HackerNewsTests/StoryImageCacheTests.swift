//
//  StoryImageCacheTests.swift
//  HackerNewsTests
//
//  Created by Kenichi Fujita on 9/16/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import XCTest
@testable import HackerNews

class StoryImageCacheTests: XCTestCase {

    var userDefaults: UserDefaults!
    let key = "touchIcon"

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }

    override func tearDownWithError() throws { }

    func testInit() {
        setImageInfoForUserDefaults(numberOfInfo: 5)
        let storyImageCache = StoryImageCache(userDefaults: self.userDefaults)
        XCTAssertEqual(storyImageCache.imageInfos.count, 5)
        for i in 1...5 {
            XCTAssertEqual(storyImageCache.imageInfos["testStoryHost\(i)"]!.url, URL(string: "testURL\(i)"))
        }
    }

    func testAddStoryImageInfoAndDidEnterBackground() {
        let addedImageInfoHost = "AddedImageInfoHost"
        let addedImageInfoURL = "AddedImageInfoURL"
        let storyImageCache = StoryImageCache(userDefaults: userDefaults)
        XCTAssertEqual(storyImageCache.imageInfos.count, 0)

        // Add storyImageInfo to StoryImageCache while not cached to UserDefaults.
        storyImageCache.addStoryImageInfo(storyHost: addedImageInfoHost, storyImageInfo: StoryImageInfo(url: URL(string: addedImageInfoURL)!))
        XCTAssertEqual(storyImageCache.imageInfos.count, 1)
        XCTAssertEqual(storyImageCache.imageInfos[addedImageInfoHost]!.url, URL(string: addedImageInfoURL))
        XCTAssertNil(userDefaults.data(forKey: StoryImageCache.key))

        // storyImageInfo is cached when didEnterBackgroundNotification called.
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        let imageInfosInUserDefaults = try! JSONDecoder().decode([String: StoryImageInfo].self, from: userDefaults.data(forKey: self.key)!)
        XCTAssertEqual(imageInfosInUserDefaults.count, 1)
        XCTAssertEqual(imageInfosInUserDefaults[addedImageInfoHost]!.url, URL(string: addedImageInfoURL))
    }

}

extension StoryImageCacheTests {
    func setImageInfoForUserDefaults(numberOfInfo number: Int) {
        var storyImageInfos: [String: StoryImageInfo] = [:]
        for i in 1...number {
            let storyHost = "testStoryHost\(i)"
            storyImageInfos[storyHost] = StoryImageInfo(url: URL(string: "testURL\(i)")!)
        }
        let encoded = try! JSONEncoder().encode(storyImageInfos)
        userDefaults.set(encoded, forKey: key)
    }
}
