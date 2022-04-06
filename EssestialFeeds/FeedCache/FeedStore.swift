//
//  FeedStore.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	
	typealias InsertionCompletion = (Error?) -> Void
	func insert(_ items: [FeedItem],timestamp: Date,completion: @escaping InsertionCompletion)
	
}
