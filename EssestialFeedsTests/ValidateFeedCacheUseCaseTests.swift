//
//  ValidateFeedCacheUseCaseTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 09/04/22.
//

import XCTest
import EssestialFeeds

class ValidateFeedCacheUseCaseTests: XCTestCase {
	
	//Local feed loader does not message store upon creation(before validating the cache feed))
	func test_init_DoesNotMessageStoreUponCreation() {
		let (_,store) = makeSUT()
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_validateCache_deletesCacheOnValidationError() {
		let (sut,store) = makeSUT()
		
		sut.validateCache()
		
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
		let (sut,store) = makeSUT()
		
		sut.validateCache()
		
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThan7daysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: lessThan7daysOldTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	//MARK: - HELPERS -
	
	func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store,currentDate: currentDate)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return (sut,store)
	}
}
