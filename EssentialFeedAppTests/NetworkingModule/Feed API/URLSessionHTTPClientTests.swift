//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 11/11/20.
//

import XCTest
@testable import EssentialFeedApp


class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        // given
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://any-url.com")!
        let requestError = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, error: requestError)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        // when
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, requestError.domain)
                XCTAssertEqual(receivedError.code, requestError.code)
            default:
                XCTFail("Expected failure with error: \(requestError), but got result: \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        static var stubs: [URL: Stub] = [:]
        
        struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
    }
    
}
