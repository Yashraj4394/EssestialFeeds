//
//  FeedStoreSpy.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 07/04/22.
//

import Foundation
import EssestialFeeds

//the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
class FeedStoreSpy: FeedStore {
	
	private var deletionCompletions = [DeletionCompletion]()
	
	private var insertionCompletions = [InsertionCompletion]()
	
	private var retrievalCompletions = [RetrievalCompletion]()
	
	enum ReceivedMessages: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage],Date)
		case retrieve
	}
	
	private(set) var receivedMessages = [ReceivedMessages]()
	
	func deleteCacheFeed(completion: @escaping DeletionCompletion){
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCachedFeed)
	}
	
	func completeDeletion(with error:Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {
		receivedMessages.append(.insert(feed, timestamp))
		insertionCompletions.append(completion)
	}
	
	func completeInsertion(with error: Error,at index: Int = 0) {
		insertionCompletions[index](error)
	}
	
	func completeInsertionSuccessfuly(at index: Int = 0){
		insertionCompletions[index](nil)
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		retrievalCompletions.append(completion)
		receivedMessages.append(.retrieve)
	}
	
	func completeRetrieval(with error: Error,at index: Int = 0) {
		retrievalCompletions[index](error)
	}
	
	func completeRetrievalWithEmptyCache(at index: Int = 0) {
		retrievalCompletions[index](nil)
	}
}