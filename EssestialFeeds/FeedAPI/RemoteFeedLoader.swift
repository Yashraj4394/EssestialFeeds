//
//  RemoteFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 20/03/22.
//

import Foundation

public protocol HTTPClient {
	
	func getFrom(from url: URL)
}

public final class RemoteFeedLoader {
	
	private let url: URL
	
	private let client : HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(){
		client.getFrom(from: url)
	}
}
