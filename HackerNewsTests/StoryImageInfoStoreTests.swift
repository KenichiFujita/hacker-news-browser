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

    override func setUpWithError() throws {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.error = nil
    }

    override func tearDownWithError() throws { }

    func testImageIconURL_WhenSuccessfulHTMLProvidedAndCached() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let testStoryURL = URL(string: "https://test.url.com/story")!

        // Should return nil as there is no cached StoryImageInfo for key testStoryURL host and no htmlData is provided.
        MockURLProtocol.error = NSError(domain: "", code: 0, userInfo: nil)
        let expectation1 = XCTestExpectation()
        storyImageInfoStore.imageIconURL(for: testStoryURL, completionHandler: { imageIconURL in
            XCTAssertNil(imageIconURL)
            XCTAssertNil(MockURLProtocol.stubResponseData)
            XCTAssertNil(storyImageInfoCache.storyImageInfo(forKey: testStoryURL.host!))
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 1)

        // Fetch testStoryURL's imageIconURL from htmlData and cache it in StoryImageInfoCache.
        let path = Bundle.main.path(forResource: "StoryImageInfoData", ofType: "html")!
        let htmlData = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlData
        MockURLProtocol.error = nil
        let testStoryTouchIconURL = URL(string: "https://test.url.com/apple-touch-icon-114x114-precomposed.png")!
        let expectation2 = XCTestExpectation()
        storyImageInfoStore.imageIconURL(for: testStoryURL, completionHandler: { imageIconURL in
            XCTAssertEqual(imageIconURL, testStoryTouchIconURL)
            expectation2.fulfill()
        })
        self.wait(for: [expectation2], timeout: 1)

        // Should fetch imageIconURL from cache. If there is no cache, it should return nil as stubResponseData is nil.
        MockURLProtocol.stubResponseData = nil
        let expectation3 = XCTestExpectation()
        storyImageInfoStore.imageIconURL(for: testStoryURL, completionHandler: { imageIconURL in
            XCTAssertEqual(imageIconURL, testStoryTouchIconURL)
            expectation3.fulfill()
        })
        self.wait(for: [expectation3], timeout: 1)
    }

    func testImageIconURL_WhenURLHasInvalidHost() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let testStoryURLWithInvalidHost = URL(string: "testURLWithInvalidHost")!

        // Should return nil as invalid url host is provided
        let expectation1 = XCTestExpectation()
        storyImageInfoStore.imageIconURL(for: testStoryURLWithInvalidHost, completionHandler: { imageIconURL in
            XCTAssertNil(imageIconURL)
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 1)
    }

    func testOgImage_WhenSuccessfulHTMLProvided() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let testStoryURL = URL(string: "https://test.url.com/story")!
        let path = Bundle.main.path(forResource: "StoryImageInfoData", ofType: "html")!
        let htmlData = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlData
        let stubbedOgImageURL = URL(string: "https://www.test.url.com/images/ogimage.png")
        let expectation = XCTestExpectation()

        // Should fetch ogImageURL
        storyImageInfoStore.ogImageURL(url: testStoryURL, completionHandler: { ogImageURL in
            XCTAssertEqual(ogImageURL, stubbedOgImageURL)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testOgImage_WhenInvalidHTMLProvided() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let testStoryURL = URL(string: "https://test.url.com/story")!
        MockURLProtocol.error = NSError(domain: "", code: 0, userInfo: nil)
        let expectation = XCTestExpectation()

        // Should return nil
        storyImageInfoStore.ogImageURL(url: testStoryURL, completionHandler: { ogImageURL in
            XCTAssertNil(ogImageURL)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testOgImage_WhenHTMLDoesNotHaveOgImage() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let storyImageInfoCache = MockStoryImageInfoCache()
        let storyImageInfoStore = StoryImageInfoStore(session: session, storyImageInfoCache: storyImageInfoCache)
        let testStoryURL = URL(string: "https://test.url.com/story")!
        let path = Bundle.main.path(forResource: "StoryImageInfoDataWithoutOgImage", ofType: "html")!
        let htmlData = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = htmlData
        let expectation = XCTestExpectation()

        // Should return nil
        storyImageInfoStore.ogImageURL(url: testStoryURL, completionHandler: { ogImageURL in
            XCTAssertNil(ogImageURL)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

}

private class MockStoryImageInfoCache: ImageInfoCacheProtocol {

    private var storyImageInfos: [String: StoryImageInfo] = [:]

    func add(_ storyImageInfo: StoryImageInfo, forKey key: String) {
        storyImageInfos[key] = storyImageInfo
    }

    func storyImageInfo(forKey key: String) -> StoryImageInfo? {
        return storyImageInfos[key]
    }

}
