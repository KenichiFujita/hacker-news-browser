//
//  StoryStoreTests.swift
//  HackerNewsTests
//
//  Created by Kenichi Fujita on 8/31/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import XCTest
@testable import HackerNews

class StoryStoreTests: XCTestCase {

    var storyStore: StoryStore!

    override func setUpWithError() throws {
        storyStore = StoryStore(api: MockAPIClient())
    }

    override func tearDownWithError() throws {
        storyStore = nil
        MockAPIClient.result = nil
    }

    func testStories_WhenNoIDsFetched_ShouldReturnEmptyArray() {
        MockAPIClient.result = .success([])
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories, [])
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    func testStories_WhenStoriesFetchedForFirstTimeAndStoriesLessThanLimit_ShouldReturnRestOfStories() {
        MockAPIClient.result = .success(Array(0 ... 3))
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.count, 4)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    func testStories_WhenStoriesMethodCalledForSecondTime_ShouldReturnRangeOfStories() {
        let limit = 5
        MockAPIClient.result = .success(Array(0 ... 15))
        let firstExpectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: limit, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.first?.by, "testUser0")
            XCTAssertEqual(stories.last?.by, "testUser4")
            firstExpectation.fulfill()
        })
        storyStore.stories(for: .top, offset: (0 + limit), limit: 5, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.first?.by, "testUser5")
            XCTAssertEqual(stories.last?.by, "testUser9")
            XCTAssertEqual(stories.count, 5)
            secondExpectation.fulfill()
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenStoriesMethodCalledForSecondTimeAndStoriesLessThanLimit_ShouldReturnRestOfStories() {
        let limit = 5
        MockAPIClient.result = .success(Array(0 ... 7))
        let firstExpectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: limit, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.first?.by, "testUser0")
            XCTAssertEqual(stories.last?.by, "testUser4")
            firstExpectation.fulfill()
        })
        storyStore.stories(for: .top, offset: (0 + limit), limit: limit, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.first?.by, "testUser5")
            XCTAssertEqual(stories.last?.by, "testUser7")
            secondExpectation.fulfill()
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenStoriesMethodCalledForSecondTimeButNoStoriesToFetch_ShouldReturnEmptyArray() {
        let limit = 5
        MockAPIClient.result = .success(Array(0 ... 4))
        let firstExpectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: limit, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories.first?.by, "testUser0")
            XCTAssertEqual(stories.last?.by, "testUser4")
            firstExpectation.fulfill()
        })
        storyStore.stories(for: .top, offset: (0 + limit), limit: limit, completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories, [])
            secondExpectation.fulfill()
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenIDsMethodFailDecoding_ShouldReturnError() {
        MockAPIClient.result = .failure(.decodingError)
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.decodingError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    func testStories_WhenIDsMethodFailHTTMRequest_ShouldReturnError() {
        MockAPIClient.result = .failure(.domainError)
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.domainError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

}

private class MockAPIClient: APIClient {

    static var result: Result<[Int], APIClientError>!

    override func ids(for type: StoryQueryType, completionHandler: @escaping (Result<[Int], APIClientError>) -> Void) {
        completionHandler(MockAPIClient.result)
    }

    override func stories(for ids: [Int], completionHandler: @escaping ([Story]) -> Void) {
        completionHandler(ids.map { Story(id: $0) })
    }

}

extension Story {
    fileprivate init(id: Int) {
        self.init(by: "testUser\(id)", descendants: id, id: id, score: id, date: Date(), title: "Test Title \(id)", url: "testURL", text: "Test Text \(id)")
    }
}
