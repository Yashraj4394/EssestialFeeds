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

public typealias RetrieveCachedFeedResult = Result<CacheFeed,Error>

public enum CacheFeed {
	case empty
	case found(feed: [LocalFeedImage],timestamp: Date)
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	
	///The completion handler can be invoked in any thread.
	///Clients are responsible to dispatch to appropriate threads, if needed.
	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	
	///The completion handler can be invoked in any thread.
	///Clients are responsible to dispatch to appropriate threads, if needed.
	func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
	
	
	///The completion handler can be invoked in any thread.
	///Clients are responsible to dispatch to appropriate threads, if needed.
	func retrieve(completion: @escaping RetrievalCompletion)
	
}
