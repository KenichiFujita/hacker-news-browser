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

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testStories_WhenNoIDsFetched_ShouldReturnEmptyArray() {
        let storyStore = StoryStore(api: MockAPIClient(result: .success([])))
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
        let storyStore = StoryStore(api: MockAPIClient(result: .success(Array(0...3))))
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
        let storyStore = StoryStore(api: MockAPIClient(result: .success(Array(0...15))))
        let limit = 5
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
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenStoriesMethodCalledForSecondTimeAndStoriesLessThanLimit_ShouldReturnRestOfStories() {
        let storyStore = StoryStore(api: MockAPIClient(result: .success(Array(0...7))))
        let limit = 5
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
            storyStore.stories(for: .top, offset: (0 + limit), limit: limit, completionHandler: { result in
                guard case .success(let stories) = result else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(stories.first?.by, "testUser5")
                XCTAssertEqual(stories.last?.by, "testUser7")
                secondExpectation.fulfill()
            })
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenStoriesMethodCalledForSecondTimeButNoStoriesToFetch_ShouldReturnEmptyArray() {
        let storyStore = StoryStore(api: MockAPIClient(result: .success(Array(0...4))))
        let limit = 5
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
            storyStore.stories(for: .top, offset: (0 + limit), limit: limit, completionHandler: { result in
                guard case .success(let stories) = result else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(stories, [])
                secondExpectation.fulfill()
            })
        })
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }

    func testStories_WhenIDsMethodFailDecoding_ShouldReturnError() {
        let storyStore = StoryStore(api: MockAPIClient(result: .failure(.decodingError)))
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertNotNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    func testStories_WhenIDsMethodFailHTTMRequest_ShouldReturnError() {
        let storyStore = StoryStore(api: MockAPIClient(result: .failure(.domainError)))
        let expectation = XCTestExpectation()

        storyStore.stories(for: .top, offset: 0, limit: 5, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertNotNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

}

private class MockAPIClient: APIClient {

    private var result: Result<[Int], APIClientError>!

    init(result: Result<[Int], APIClientError>) {
        self.result = result
    }

    override func ids(for type: StoryQueryType, completionHandler: @escaping (Result<[Int], APIClientError>) -> Void) {
        completionHandler(result)
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
