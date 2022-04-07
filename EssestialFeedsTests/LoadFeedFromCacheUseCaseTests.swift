//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 07/04/22.
//

import XCTest
import EssestialFeeds

class LoadFeedFromCacheUseCaseTests: XCTestCase {
	
	//does not delete cache upon creation
	func test_init_DoesNotMessageStoreUponCreation() {
		let (_,store) = makeSUT()
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	//MARK: - HELPERS -
	
	func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store,currentDate: currentDate)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return (sut,store)
	}
	
	//the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
	class FeedStoreSpy: FeedStore {
		
		private var deletionCompletions = [DeletionCompletion]()
		
		private var insertionCompletions = [InsertionCompletion]()
		
		enum ReceivedMessages: Equatable {
			case deleteCachedFeed
			case insert([LocalFeedImage],Date)
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
	}

}

