//
//  URLSessionHTTPClientTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/03/22.
//

import XCTest
import EssestialFeeds

class URLSessionHTTPClient {
	private let session : URLSession
	
	init(session:URLSession = .shared) {
		self.session = session
	}
	
	func get(from url: URL,completion: @escaping(HTTPClientResult)->Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			}
			
		}.resume()
	}
}

class URLSessionHTTPClientTests: XCTestCase {
	
	func test_getFromURL_failsOnRequestError(){
		URLProtocolStub.startInterceptingRequests()
		
		let url = URL(string: "https://www.a-url.com")!
		let error = NSError(domain: "any error", code: 1)
		
		URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
		
		let sut = URLSessionHTTPClient()
			//as getMethod is async, we have add expectation
		let exp = expectation(description: "wait for completion")
		
		sut.get(from : url) { result in
			switch result {
				case let .failure(receivedError as NSError):
					XCTAssertEqual(receivedError.code, error.code)
					XCTAssertEqual(receivedError.domain, error.domain)
				default:
					XCTFail("Expected failure with error \(error) but got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		URLProtocolStub.stopInterceptingRequests()
	}


	//MARK: - HELPERS
	//class URLProtocol : NSObject : An abstract class that handles the loading of protocol-specific URL data.
	private class URLProtocolStub: URLProtocol {
		private static var stubs = [URL:Stub]()
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		
		}
		
		static func stub(url: URL,data: Data?,response: URLResponse?, error: Error?) {
			stubs[url] = Stub(data: data, response: response, error: error)
		}
		
	
		static func startInterceptingRequests(){
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests(){
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stubs = [:]
		}
		
		/*
				@method canInitWithRequest:
				@abstract This method determines whether this protocol can handle
				the given request.
				@discussion A concrete subclass should inspect the given request and
				determine whether or not the implementation can perform a load with
				that request. This is an abstract method. Sublasses must provide an
				implementation.
				@param request A request to inspect.
				@result YES if the protocol can handle the given request, NO if not.
		*/
		
		override class func canInit(with request: URLRequest) -> Bool {
			guard let url = request.url else {return false}
			
			return URLProtocolStub.stubs[url] != nil
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		/*
		 @method startLoading
		 @abstract Starts protocol-specific loading of a request.
		 @discussion When this method is called, the protocol implementation
		 should start loading a request.
		 */
		override func startLoading() {
			guard let url = request.url , let stub = URLProtocolStub.stubs[url] else {return}
			
			if let error = stub.error {
				//Client: The object the protocol uses to communicate with the URL loading system.
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			if let data = stub.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = stub.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			
			client?.urlProtocolDidFinishLoading(self)
			
		}
		
		/*
				@method stopLoading
				@abstract Stops protocol-specific loading of a request.
				@discussion When this method is called, the protocol implementation
				should end the work of loading a request. This could be in response
				to a cancel operation, so protocol implementations must be able to
				handle this call while a load is in progress.
		*/
		override func stopLoading() {}
	}
}
