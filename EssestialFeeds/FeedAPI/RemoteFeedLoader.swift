//
//  RemoteFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 20/03/22.
//

import Foundation

public final class RemoteFeedLoader{
	
	private let url: URL
	
	private let client : HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = LoadFeedResult<Error>
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void){
		client.getFrom(from: url) { [weak self] result in
			guard self != nil else {return}
			switch result {
				case let .success(data, response):
					completion(FeedItemsMapper.map(data, from : response))
				case .failure:
					completion(.failure(.connectivity))
			}
		}
	}
}

