//
//  RemoteFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 20/03/22.
//

import Foundation

public protocol HTTPClient {
	
	func getFrom(from url: URL,completion: @escaping(Error) -> Void)
}

public final class RemoteFeedLoader {
	
	private let url: URL
	
	private let client : HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Error) -> Void){
		client.getFrom(from: url) { error in
			completion(.connectivity)
		}
	}
}
