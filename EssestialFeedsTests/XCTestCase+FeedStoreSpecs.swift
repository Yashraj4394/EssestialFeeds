//
//  XCTestCase+FeedStoreSpecs.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 21/04/22.
//

import EssestialFeeds
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .success(.empty), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .success(.empty), file: file, line: line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp),sut)
		
		expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), sut)
		
		expect(sut, toRetrieveTwice: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().local, Date()), sut)
		
		XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), sut)
		
		let insertionError = insert((uniqueImageFeed().local, Date()), sut)
		
		XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
	}
	
	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), sut)
		
		expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(.empty), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), sut)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), sut)
		
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(.empty), file: file, line: line)
	}
	
	func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.deleteCacheFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0)
		
		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}
	
}

///We constrain the protocol extension to XCTestCase subclasses since the helpers use XCTestCase methods. Also, it serves as documentation denothing this protocol extension is for tests only.
extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache:(feed: [LocalFeedImage],timestamp: Date),_ sut: FeedStore) -> Error? {
		let exp = expectation(description: "wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		
		sut.deleteCacheFeed { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore,toRetrieveTwice expectedResult: FeedStore.RetrievalResult,file: StaticString = #filePath, line: UInt = #line) {
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
	}
	
	func expect(_ sut: FeedStore,toRetrieve expectedResult: FeedStore.RetrievalResult,file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.retrieve { retrivedResult in
			
			switch (retrivedResult,expectedResult) {
				case ((.success(.empty),.success(.empty))) , ((.failure),.failure):
					break
//				case (.empty, .empty), (.failure, .failure):
//					break
				case let (.success(.found(feed: expectedFeed, timestamp: expectedTimeStamp)),.success(.found(feed: retrievedFeed, timestamp: retrievedTimestap))):
					XCTAssertEqual(expectedFeed, retrievedFeed,file:file,line: line)
					XCTAssertEqual(expectedTimeStamp,retrievedTimestap,file:file,line: line)
					
				default:
					XCTFail("expected to retieve \(expectedResult), got \(retrivedResult) instead",file:file,line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
