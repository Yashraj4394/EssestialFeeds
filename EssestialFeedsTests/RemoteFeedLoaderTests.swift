//
//  RemoteFeedLoaderTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/03/22.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDatFromURL(){ // asset that url should be nil unless load function is called from RemoteFeedLoader
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let _ = RemoteFeedLoader()
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL(){
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let sut = RemoteFeedLoader()
		sut.load()
		XCTAssertNotNil(client.requestedURL)
	}
}

class RemoteFeedLoader {
	func load(){
		HTTPClient.shared.getFrom(from: URL(string: "https://www.a-url.com")!)
	}
}

//http client that is going to connect with the network
class HTTPClient {
	static var shared = HTTPClient() // making this var will result in making this class as a global state. This is not singleton anymore.
	//removed private init as this class is not singleton anymore
	
	func getFrom(from url: URL) {}
}

// created a new subclass so that it can be tested as HTTPClient will be part of production code and we dont want requeted url to be a part of it. Test logic is now in the spy
class HTTPClientSpy: HTTPClient {
	override func getFrom(from url: URL) {
		requestedURL = url
	}
	var requestedURL: URL?
}
