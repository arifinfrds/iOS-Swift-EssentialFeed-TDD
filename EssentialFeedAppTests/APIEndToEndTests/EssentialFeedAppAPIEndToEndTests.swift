//
//  EssentialFeedAppAPIEndToEndTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 23/12/20.
//

import XCTest
@testable import EssentialFeedApp

class EssentialFeedAppAPIEndToEndTests: XCTestCase {
    
    func test_endToEndServerGETFeedResult_matchesFixedTestsAccountData() {
        // when & then
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8)
            XCTAssertEqual(items[0], makeExpectedItem(at: 0))
            XCTAssertEqual(items[1], makeExpectedItem(at: 1))
            XCTAssertEqual(items[2], makeExpectedItem(at: 2))
            XCTAssertEqual(items[3], makeExpectedItem(at: 3))
            XCTAssertEqual(items[4], makeExpectedItem(at: 4))
            XCTAssertEqual(items[5], makeExpectedItem(at: 5))
            XCTAssertEqual(items[6], makeExpectedItem(at: 6))
            XCTAssertEqual(items[7], makeExpectedItem(at: 7))
            
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead.")
        default:
            XCTFail("Expected successful feed result, get no result instead.")
        }
    }
    
    
    // MARK: - Helpers
    
    func getFeedResult() -> LoadFeedResult? {
        // given
        let testServerURL = "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json"
        let url = URL(string: testServerURL)!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(for: client)
        trackForMemoryLeaks(for: loader)
        
        // when
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: RemoteFeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func makeExpectedItem(at index: Int) -> FeedItem {
        return FeedItem(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index)
        )
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
}
