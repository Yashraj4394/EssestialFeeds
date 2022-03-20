//
//  RemoteFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 20/03/22.
//

import Foundation

public enum HTTPClientResult {
	 case success(Data,HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	
	func getFrom(from url: URL,completion: @escaping(HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
	
	private let url: URL
	
	private let client : HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public enum Result: Equatable {
		case success([FeedItem])
		case failure(Error)
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void){
		client.getFrom(from: url) { result in
			switch result {
				case let .success(data, _):
					if let _ = try?  JSONSerialization.jsonObject(with: data) {
						completion(.success([]))
					} else {
						completion(.failure(.invalidData))
					}
					
//					break
				case .failure:
					completion(.failure(.connectivity))
			}
		}
	}
}
