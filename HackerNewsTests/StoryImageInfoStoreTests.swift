//
//  StoryImageInfoStore.swift
//  HackerNewsTests
//
//  Created by Kenichi Fujita on 9/18/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import XCTest
@testable import HackerNews

class StoryImageInfoStoreTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.error = nil
    }

    func testImageIconURL() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let path = Bundle.main.path(forResource: "HTML", ofType: "txt")!
        let htmlInText = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlInText
        let testStoryURLString = "https://test.url.com/story_"
        let testStory1 = testStoryURLString + "1"
        let testStory2 = testStoryURLString + "2"
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        let expectation3 = XCTestExpectation()
        let expectation4 = XCTestExpectation()

        // To ensure no StoryImageInfo is stored in cache
        XCTAssertEqual(storyImageInfoCache.imageInfos.count, 0)

        // Fetch imageIconURL that has not been cached
        storyImageInfoStore.imageIconURL(url: testStory1, host: URL(string: testStory1)!.host!, completionHandler: { imageIconURL in
            XCTAssertEqual(imageIconURL, URL(string: "https://test.url.com/apple-touch-icon-114x114-precomposed.png"))
            XCTAssertEqual(storyImageInfoCache.imageInfos.count, 1)
            XCTAssertEqual(storyImageInfoCache.imageInfos[URL(string: testStory1)!.host!]?.url, URL(string: testStory1))
            XCTAssertEqual(Thread.isMainThread, true)
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 3)

        // Fetch imageIconURL that has been cached
        storyImageInfoStore.imageIconURL(url: testStory2, host: URL(string: testStory2)!.host!, completionHandler: { imageIconURL in
            XCTAssertEqual(imageIconURL, URL(string: "https://test.url.com/apple-touch-icon-114x114-precomposed.png"))
            XCTAssertEqual(storyImageInfoCache.imageInfos.count, 1)
            XCTAssertEqual(storyImageInfoCache.imageInfos[URL(string: testStory2)!.host!]?.url, URL(string: testStory1))
            XCTAssertEqual(Thread.isMainThread, true)
            expectation2.fulfill()
        })
        wait(for: [expectation2], timeout: 3)

        // Return nil when invalid url provided
        storyImageInfoStore.imageIconURL(url: "invalidURL{}", host: "invalidURL{}Host", completionHandler: { imageIconURL in
            XCTAssertNil(imageIconURL)
            XCTAssertEqual(storyImageInfoCache.imageInfos.count, 1)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation3.fulfill()
        })
        wait(for: [expectation3], timeout: 3)

        // Return nil when html() fail to fetch data
        MockURLProtocol.error = NSError(domain: "", code: 0, userInfo: nil)
        storyImageInfoStore.imageIconURL(url: "https://error.com", host: "error.com", completionHandler: { imageIconURL in
            XCTAssertNil(imageIconURL)
            XCTAssertEqual(storyImageInfoCache.imageInfos.count, 1)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation4.fulfill()
        })
        wait(for: [expectation4], timeout: 3)
    }

    func testOgImageURL() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let path1 = Bundle.main.path(forResource: "HTML", ofType: "txt")!
        let htmlWithOgImageInText = try! String(contentsOfFile: path1).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlWithOgImageInText
        let testStoryURLString = "https://test.url.com/story_"
        let testStory1 = testStoryURLString + "1"
        let expectation1 = XCTestExpectation()

        // Return og:image URL when the website has og:image
        storyImageInfoStore.ogImageURL(url: testStory1, completionHandler: { ogImageURL in
            XCTAssertEqual(ogImageURL, URL(string: "https://www.test.url.com/images/ogimage.png"))
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 3)

        // Return nil when the website does not have og:image
        let path2 = Bundle.main.path(forResource: "HTMLWithoutOgImage", ofType: "txt")!
        let htmlWithoutOgImageInText = try! String(contentsOfFile: path2).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlWithoutOgImageInText
        let testStory2 = testStoryURLString + "2"
        let expectation2 = XCTestExpectation()
        storyImageInfoStore.ogImageURL(url: testStory2, completionHandler: { ogImageURL in
            XCTAssertNil(ogImageURL)
            expectation2.fulfill()
        })
        wait(for: [expectation2], timeout: 3)

        // Return nil when html() fails to fetch data
        let testStory3 = testStoryURLString + "3"
        let expectation3 = XCTestExpectation()
        MockURLProtocol.error = NSError(domain: "", code: 0, userInfo: nil)
        storyImageInfoStore.ogImageURL(url: testStory3, completionHandler: { ogImageURL in
            XCTAssertNil(ogImageURL)
            expectation3.fulfill()
        })
        wait(for: [expectation3], timeout: 3)
    }

}

private class MockStoryImageInfoCache: ImageInfoCacheProtocol {

    private var storyImageInfos: [String: StoryImageInfo] = [:]
    var imageInfos: [String : StoryImageInfo] {
        return storyImageInfos
    }

    func addStoryImageInfo(storyHost: String, storyImageInfo: StoryImageInfo) {
        storyImageInfos[storyHost] = storyImageInfo
    }

}
