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
		
		expect(sut, toCompleteWith: .connectivity, when: {
			
			let clientError = NSError(domain: "test", code: 0)
			client.complete(with: clientError)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse(){
		let (sut,client) = makeSUT()
		let samples = [199,201,300,400,400]
		samples.enumerated().forEach { (index,code) in
			expect(sut, toCompleteWith: .invalidData, when: {
				client.complete(withStatusCode: code,at: index)
			})
		}
	}
	
	//success with 200 but invalid json
	func test_load_deliversErrorOn200HTTPResponseWithInvalidData(){
		let (sut,client) = makeSUT()
		expect(sut, toCompleteWith: .invalidData, when: {
			let invalidJson = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJson)
		})
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
		let (sut,client) = makeSUT()
		var capturedErrors = [RemoteFeedLoader.Result]()
		sut.load { capturedErrors.append($0)}
		
		let emptyListJSON = Data("{\"items\" : []}".utf8)
		client.complete(withStatusCode: 200, data: emptyListJSON)
		XCTAssertEqual(capturedErrors, [.success([])])
	}
	
	//MARK: HELPERS
	private func makeSUT(url: URL =  URL(string: "https://www.a-url.com")!) -> (sut:RemoteFeedLoader,client: HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut,client)
	}
	
	private func expect(_ sut: RemoteFeedLoader,toCompleteWith error: RemoteFeedLoader.Error,when action: () -> Void,file: StaticString = #filePath, line: UInt = #line) {
		var capturedErrors = [RemoteFeedLoader.Result]()
		sut.load { capturedErrors.append($0)}
		action()
		XCTAssertEqual(capturedErrors, [.failure(error)],file: file,line: line)
	}
	
	private class HTTPClientSpy: HTTPClient {

		private var messages = [(url: URL,completion: (HTTPClientResult) -> Void)]()
		
		var requestedURLs : [URL] {
			return messages.map({$0.url})
		}
		
		func getFrom(from url: URL,completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url,completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int,data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil
			)!
			messages[index].completion(.success(data,response))
		}
	}
	
}
