//
//  RemoteFeedLoaderTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/03/22.
//

import XCTest
import EssestialFeeds

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDatFromURL(){ // asset that url should be nil unless load function is called from RemoteFeedLoader
		let (_, client) = makeSUT()
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL(){
		let url = URL(string: "https://www.a-new-url.com")!
		let (sut,client) = makeSUT(url: url)
		sut.load { _ in}
		XCTAssertEqual(client.requestedURLs,[url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice(){
		let url = URL(string: "https://www.a-new-url.com")!
		let (sut,client) = makeSUT(url: url)
		sut.load { _ in}
		sut.load { _ in}
		XCTAssertEqual(client.requestedURLs,[url,url])
	}
	
	func test_load_deliversErrorOnClientError(){
		let (sut,client) = makeSUT()
		
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load { capturedErrors.append($0)}
		
		let clientError = NSError(domain: "test", code: 0)
		client.complete(with: clientError)
		XCTAssertEqual(capturedErrors, [.connectivity])
	}
	
	//MARK: HELPERS
	private func makeSUT(url: URL =  URL(string: "https://www.a-url.com")!) -> (sut:RemoteFeedLoader,client: HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut,client)
	}
	
	private class HTTPClientSpy: HTTPClient {

		private var messages = [(url: URL,completion: (Error) -> Void)]()
		
		var requestedURLs : [URL] {
			return messages.map({$0.url})
		}
		
		func getFrom(from url: URL,completion: @escaping (Error) -> Void) {
			messages.append((url,completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(error)
		}
	}
	
}
