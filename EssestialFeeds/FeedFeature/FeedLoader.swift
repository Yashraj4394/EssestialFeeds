//
//  FeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 19/03/22.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
	case success([FeedItem])
	case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
	associatedtype Error: Swift.Error
	func load(completions: @escaping (LoadFeedResult<Error>) -> Void)
}
