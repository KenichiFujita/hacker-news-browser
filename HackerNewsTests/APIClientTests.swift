//
//  APIClientTests.swift
//  HackerNewsUITests
//
//  Created by Kenichi Fujita on 8/23/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import XCTest
@testable import HackerNews

class APIClientTests: XCTestCase {
    
    var api: APIClient!

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        api = APIClient(session: session)
    }

    override func tearDownWithError() throws {
        api = nil
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.error = nil
    }
    
    func testSearchStories_WhenSuccessfulDataFetched_ShouldReturnStories() {
        let path = Bundle.main.path(forResource: "SuccessfulSearchStoriesData", ofType: "json")!
        let jsonData = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = jsonData
        let expectation = XCTestExpectation()

        api.searchStories(searchText: "test", completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories[0].title, "A Most Peculiar Test Drive")
            XCTAssertEqual(stories[1].title, "Google's “Director of Engineering” Hiring Test")
            XCTAssertEqual(stories[2].title, "Blender is testing PeerTube after YouTube blocks their videos worldwide")
            XCTAssertEqual(stories[0].by, "reneherse")
            XCTAssertEqual(stories[1].by, "fatihky")
            XCTAssertEqual(stories[2].by, "gargron")
            XCTAssertEqual(stories[0].descendants, 581)
            XCTAssertEqual(stories[1].descendants, 923)
            XCTAssertEqual(stories[2].descendants, 426)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testSearchStories_WhenEmptySearchTextPassed_ShouldReturnEmptyArray() {
        let expectation = XCTestExpectation()

        api.searchStories(searchText: "", completionHandler: { result in
            guard case .success(let stories) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(stories, [])
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testSearchStories_WhenHTTPRequestFailed_ShouldReturnError() {
        MockURLProtocol.error = APIClientError.domainError
        let expectation = XCTestExpectation()

        api.searchStories(searchText: "test", completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.domainError)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testSearchStories_WhenInvalidJSONFetched_ShouldReturnError() {
        let invalidJSONData = "null".data(using: .utf8)
        MockURLProtocol.stubResponseData = invalidJSONData
        let expectation = XCTestExpectation()

        api.searchStories(searchText: "test", completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.decodingError)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testComment_WhenSuccessfulDataFetched_ShouldReturnComments() {
        let path = Bundle.main.path(forResource: "SuccessfulCommentsData", ofType: "json")!
        let jsonData = try! String(contentsOfFile: path).data(using: .utf8)
        MockURLProtocol.stubResponseData = jsonData
        let expectation = XCTestExpectation()

        api.comment(id: 123456, completionHandler: { result in
            guard case .success(let comments) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(comments.count, 2)
            XCTAssertEqual(comments[1].comments.count, 2)
            XCTAssertEqual(comments[0].id, 11)
            XCTAssertEqual(comments[0].by, "testCommentAuthor1-a")
            XCTAssertEqual(comments[0].text, "Test Comment Text 1-a")
            XCTAssertEqual(comments[0].parent, 1)
            XCTAssertEqual(comments[0].tier, 0)
            XCTAssertEqual(comments[1].comments[0].id, 121)
            XCTAssertEqual(comments[1].comments[0].by, "testCommentAuthor1-b-a")
            XCTAssertEqual(comments[1].comments[0].text, "Test Comment Text 1-b-a")
            XCTAssertEqual(comments[1].comments[0].parent, 12)
            XCTAssertEqual(comments[1].comments[0].tier, 1)
            XCTAssertEqual(comments[1].comments[1].id, 122)
            XCTAssertEqual(comments[1].comments[1].by, "testCommentAuthor1-b-b")
            XCTAssertEqual(comments[1].comments[1].text, "Test Comment Text 1-b-b")
            XCTAssertEqual(comments[1].comments[1].parent, 12)
            XCTAssertEqual(comments[1].comments[1].tier, 1)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testComment_WhenHTTPRequestFailed_ShouldReturnError() {
        MockURLProtocol.error = APIClientError.domainError
        let expectation = XCTestExpectation()

        api.comment(id: 123456, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.domainError)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testComment_WhenInvalidJSONDataFetched_ShouldReturnError() {
        MockURLProtocol.stubResponseData = "null".data(using: .utf8)
        let expectation = XCTestExpectation()

        api.comment(id: 123456, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.decodingError)
            XCTAssertEqual(Thread.isMainThread, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}
