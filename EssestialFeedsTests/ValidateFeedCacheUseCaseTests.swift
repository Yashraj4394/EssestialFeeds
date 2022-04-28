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
	
	//less than 7 days
	func test_validateCache_doesNotDeleteOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	//exactly 7 days
	func test_validateCache_deleteOnExpirationCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: expirationTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
	}
	
	//more than 7 days
	func test_validateCache_deletesOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let exipredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.validateCache()
		
		store.completeRetrieval(with: feed.local, timestamp: exipredTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated(){
		let store = FeedStoreSpy()
		
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		sut?.validateCache()
		
		sut = nil
		
		store.completeRetrieval(with: anyNSError())
		
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
