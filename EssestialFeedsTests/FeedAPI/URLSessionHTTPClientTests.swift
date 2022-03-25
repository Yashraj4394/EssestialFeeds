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
	
	init(session:URLSession) {
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
	
	//check if task was resumed only once
	func test_getFromURL_resumeDataTaskWithURL(){
		let url = URL(string: "https://www.a-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		
		session.stub(url:url,task:task)
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from : url) { _ in}
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	
	func test_getFromURL_failsOnRequestError(){
		let url = URL(string: "https://www.a-url.com")!
		let session = URLSessionSpy()
		let error = NSError(domain: "any error", code: 1)
		session.stub(url:url,error:error)
		let sut = URLSessionHTTPClient(session: session)
			//as getMethod is async, we have add expectation
		let exp = expectation(description: "wait for completion")
		sut.get(from : url) { result in
			switch result {
				case let .failure(receivedError as NSError):
					XCTAssertEqual(receivedError, error)
				default:
					XCTFail("Expected failure with error \(error) but got \(result) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}


	//MARK: - HELPERS
	private class URLSessionSpy: URLSession {
		private var stubs = [URL:Stub]()
		
		func stub(url: URL,task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
			stubs[url] = Stub(task: task, error: error)
		}
		
		private struct Stub {
			let task: URLSessionDataTask
			let error: Error?
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			guard let stub = stubs[url] else {
				fatalError("could not find stub for \(url)")
			}
			completionHandler(nil,nil,stub.error)
			return stub.task
		}
	}
	
	private class FakeURLSessionDataTask : URLSessionDataTask {
		override func resume() {
		}
	}
	
	private class URLSessionDataTaskSpy : URLSessionDataTask {
		
		var resumeCallCount = 0
		
		override func resume() {
			resumeCallCount += 1
		}
	}
}
