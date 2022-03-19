//
//  RemoteFeedLoaderTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/03/22.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDatFromURL(){ // asset that url should be nil unless load function is called from RemoteFeedLoader
		let client = HTTPClient.shared
		let _ = RemoteFeedLoader()
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL(){
		let client = HTTPClient.shared
		let sut = RemoteFeedLoader()
		sut.load()
		XCTAssertNotNil(client.requestedURL)
	}
}

class RemoteFeedLoader {
	func load(){
		HTTPClient.shared.requestedURL = URL(string: "https://www.a-url.com")
	}
}

//http client that is going to connect with the network
class HTTPClient {
	static let shared = HTTPClient()
	private init(){}
	var requestedURL: URL?
}
