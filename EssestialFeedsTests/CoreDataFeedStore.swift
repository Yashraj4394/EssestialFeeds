//
//  CoreDataFeedStore.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/04/22.
//

import EssestialFeeds
import Foundation

public final class CoreDataFeedStore: FeedStore {
	
	public init() {}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		
	}
	
}
