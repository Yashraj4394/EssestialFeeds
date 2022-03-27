//
//  URLSessionHTTPClientTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/03/22.
//

import XCTest
import EssestialFeeds

class URLSessionHTTPClient: HTTPClient {
	
	private let session : URLSession
	
	init(session:URLSession = .shared) {
		self.session = session
	}
	
	struct UnexpectedValuesRepresentation:Error {}
	
	func get(from url: URL,completion: @escaping(HTTPClientResult)->Void) {
		session.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
			} else if let data = data, let response = response as? HTTPURLResponse {
				completion(.success(data, response))
			} else {
				completion(.failure(UnexpectedValuesRepresentation()))
			}
			
		}.resume()
	}
}

class URLSessionHTTPClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		URLProtocolStub.startInterceptingRequests()
	}
	
	override func tearDown() {
		super.tearDown()
		URLProtocolStub.stopInterceptingRequests()
	}
	
	func test_getFromURL_performGETRequestWithURL(){
		let exp = expectation(description: "wait for completion")
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, self.anyURL())
			XCTAssertEqual(request.httpMethod, "GET")
			
			exp.fulfill()
		}
		
		makeSUT().get(from: anyURL()) { _ in }
		
		wait(for: [exp], timeout: 1.0)
		
	}
	
	func test_getFromURL_failsOnRequestError() {
		let requestError = anyNSError()
		let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
		if let receivedError = receivedError as NSError? {
			XCTAssertEqual(receivedError.code, requestError.code)
			XCTAssertEqual(receivedError.domain, requestError.domain)
		} else {
			XCTFail("Not able to convert received error to NS Error")
		}
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases(){
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
	}
	
	func test_getFromURL_succeedsOnHTTPURLResponseWithValidData(){
		let data = anyData()
		let response = anyHTTPURLResponse()
		
		let receivedValues = resultValuesFor(data: data, response: response, error: nil)
		
		XCTAssertEqual(receivedValues?.data,data)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	func test_getFromURL_succeedsWithEmotyDataOnHTTPURLResponseWithNilData(){
		let response = anyHTTPURLResponse()
		let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
		
		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data,emptyData)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	//MARK: - HELPERS
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func anyURL() -> URL {
		let url = URL(string: "https://www.a-url.com")!
		return url
	}
	
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 1)
	}
	
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
	private func resultErrorFor(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #filePath, line: UInt = #line) -> Error? {
		
		let result = resultFor(data: data, response: response, error: error,file: file,line: line)
		switch result {
			case let .failure(error):
				return error
			default:
				XCTFail("Expected failure , but got \(result) instead",file: file,line: line)
				return nil
		}
	}
	
	private func resultValuesFor(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #filePath, line: UInt = #line) -> (data: Data?,response: HTTPURLResponse)? {
		let result = resultFor(data: data, response: response, error: error,file: file,line: line)
		switch result {
			case let .success(data, response):
				return (data,response)
			default:
				XCTFail("Expected success , but got \(result) instead",file: file,line: line)
				return nil
		}
	}
	
	private func resultFor(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSUT(file:file,line: line)
		
		//as getMethod is async, we have add expectation
		let exp = expectation(description: "wait for completion")
		
		var receivedResult: HTTPClientResult!
		
		sut.get(from : anyURL()) { result in
			receivedResult = result
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return receivedResult
	}
	
	//class URLProtocol : NSObject : An abstract class that handles the loading of protocol-specific URL data.
	private class URLProtocolStub: URLProtocol {
		private static var stub : Stub?
		
		private static var requestObserver:((URLRequest)->Void)?
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?,response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}
		
		static func observeRequests(observer:@escaping(URLRequest)->Void) {
			requestObserver = observer
		}
		
		static func startInterceptingRequests(){
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests(){
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
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
			
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			requestObserver?(request)
			return request
		}
		
		/*
		 @method startLoading
		 @abstract Starts protocol-specific loading of a request.
		 @discussion When this method is called, the protocol implementation
		 should start loading a request.
		 */
		override func startLoading() {
			
			if let error = URLProtocolStub.stub?.error {
				//Client: The object the protocol uses to communicate with the URL loading system.
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = URLProtocolStub.stub?.response {
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
