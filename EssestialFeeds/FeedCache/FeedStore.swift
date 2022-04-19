//
//  FeedStore.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

/*
 *** Boundry ***
 */

public enum RetrieveCachedFeedResult {
	case empty
	case found(feed: [LocalFeedImage],timestamp: Date)
  case failure(Error)
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	
	typealias InsertionCompletion = (Error?) -> Void
	func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
	
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
	func retrieve(completion: @escaping RetrievalCompletion)
}
