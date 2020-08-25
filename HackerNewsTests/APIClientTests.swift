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

    func testIds_WhenTopStoryIDsSuccessfullyFetched_ShouldReturnArrayOfInt() {
        guard let path = Bundle.main.path(forResource: "SuccessfulIDsData", ofType: "json"), let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
            XCTFail()
            return
        }
        MockURLProtocol.stubResponseData = jsonData
        let expectation = XCTestExpectation()
        
        api.ids(for: .top, completionHandler: { result in
            guard case .success(let ids) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(ids.count, 200)
            XCTAssertEqual(ids.first, 24261826)
            XCTAssertEqual(ids.last, 24241561)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 0.2)
    }
    
    func testIds_WhenInvalidJSONFetched_ShouldReturnError() {
        guard let invalidJSONData = "null".data(using: .utf8) else {
            XCTFail()
            return
        }
        MockURLProtocol.stubResponseData = invalidJSONData
        let expectation = XCTestExpectation()
        
        api.ids(for: .top, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.decodingError)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 0.2)
    }
    
    func testIds_WhenNoDataFetched_ShouldReturnError() {
        MockURLProtocol.error = APIClientError.domainError
        let expectation = XCTestExpectation()
        
        api.ids(for: .top, completionHandler: { result in
            guard case .failure(let error) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, APIClientError.domainError)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 0.2)
    }
    

    func testStories_WhenNoIDsPassed_ShouldReturnEmptyArray() {
        api.stories(for: [], completionHandler: { stories in
            XCTAssertEqual(stories, [])
        })
    }
    
    func testStories_WhenValidStoriesFetched_ShouldReturnStories() {
        guard let path = Bundle.main.path(forResource: "SuccessfulStoryData", ofType: "json"), let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
            XCTFail()
            return
        }
        MockURLProtocol.stubResponseData = jsonData
        let expectation = XCTestExpectation()
        
        api.stories(for: [1, 2, 3], completionHandler: { stories in
            XCTAssertEqual(stories.count, 3)
            XCTAssertEqual(stories[0].by, "testUser")
            XCTAssertEqual(stories[1].by, "testUser")
            XCTAssertEqual(stories[2].by, "testUser")
            XCTAssertEqual(stories[0].descendants, 1)
            XCTAssertEqual(stories[1].descendants, 1)
            XCTAssertEqual(stories[2].descendants, 1)
            XCTAssertEqual(stories[0].id, 00000001)
            XCTAssertEqual(stories[1].id, 00000001)
            XCTAssertEqual(stories[2].id, 00000001)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 0.2)
    }
    
    func testStories_WhenFetchingDataFailed_ShouldReturnValidArray() {
        MockURLProtocol.error = APIClientError.domainError
        let expectation = XCTestExpectation()
        
        api.stories(for: [1, 2, 3], completionHandler: { stories in
            XCTAssertEqual(stories, [])
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 0.2)
    }
    
    
}
