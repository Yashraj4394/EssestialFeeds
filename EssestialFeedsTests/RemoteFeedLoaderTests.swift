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
		let _ = RemoteFeedLoader(client: client)
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL(){
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(client:client)
		sut.load()
		XCTAssertNotNil(client.requestedURL)
	}
}

class RemoteFeedLoader {
	let client : HTTPClient
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(){
		client.getFrom(from: URL(string: "https://www.a-url.com")!) //RemoteFeedLoader had two responsibilities i.e responsibility of locate httpclient and responsibility of invoking a method in a object 
	}
}

//http client that is going to connect with the network
class HTTPClient {
	
	func getFrom(from url: URL) {}
}

// created a new subclass so that it can be tested as HTTPClient will be part of production code and we dont want requeted url to be a part of it. Test logic is now in the spy
class HTTPClientSpy: HTTPClient {
	override func getFrom(from url: URL) {
		requestedURL = url
	}
	var requestedURL: URL?
}
