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

public struct CacheFeed: Equatable {
	public let feed: [LocalFeedImage]
	public let timestamp: Date
	public init(feed: [LocalFeedImage],timestamp: Date) {
		self.feed = feed
		self.timestamp = timestamp
	}
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias RetrievalResult = Result<CacheFeed?,Error>
	typealias RetrievalCompletion = (RetrievalResult) -> Void
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
