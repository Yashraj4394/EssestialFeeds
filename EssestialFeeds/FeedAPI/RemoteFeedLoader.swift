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
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Error) -> Void){
		client.getFrom(from: url) { result in
			switch result {
				case .success(let hTTPURLResponse):
					completion(.invalidData)
//					break
				case .failure(let error):
					completion(.connectivity)
			}
		}
	}
}
