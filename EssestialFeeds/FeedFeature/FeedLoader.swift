//
//  FeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 19/03/22.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItem])
	case failure(Error)
}

public protocol FeedLoader {
	
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
