//
//  RemoteFeedLoaderTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/03/22.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDatFromURL(){ // asset that url should be nil unless load function is called from RemoteFeedLoader
		let client = HTTPClient()
		let _ = RemoteFeedLoader()
		XCTAssertNil(client.requestedURL)
	}
}

//http client that is going to connect with the network

class RemoteFeedLoader {
	
}

class HTTPClient {
	var requestedURL: URL?
}
