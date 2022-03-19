//
//  RemoteFeedLoaderTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/03/22.
//

import XCTest

class RemoteFeedLoader {
	let client : HTTPClient
	let url: URL
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	func load(){
		client.getFrom(from: url) //RemoteFeedLoader had two responsibilities i.e responsibility of locate httpclient and responsibility of invoking a method in a object
	}
}

//http client that is going to connect with the network

protocol HTTPClient {
	
	func getFrom(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDatFromURL(){ // asset that url should be nil unless load function is called from RemoteFeedLoader
		let (_, client) = makeSUT()
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL(){
		let url = URL(string: "https://www.a-new-url.com")!
		let (sut,client) = makeSUT(url: url)
		sut.load()
		XCTAssertEqual(client.requestedURL,url)
	}
	
	
	//MARK: HELPERS
	private func makeSUT(url: URL =  URL(string: "https://www.a-url.com")!) -> (sut:RemoteFeedLoader,client: HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut,client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		
		var requestedURL: URL?
		
		func getFrom(from url: URL) {
			requestedURL = url
		}
	}
	
}
