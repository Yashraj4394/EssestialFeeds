//
//  XCTestCase+FeedStoreSpecs.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 21/04/22.
//

import EssestialFeeds
import XCTest

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
	
	func expect(_ sut: FeedStore,toRetrieveTwice expectedResult: RetrieveCachedFeedResult,file: StaticString = #filePath, line: UInt = #line) {
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
	}
	
	func expect(_ sut: FeedStore,toRetrieve expectedResult: RetrieveCachedFeedResult,file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.retrieve { retrivedResult in
			
			switch (retrivedResult,expectedResult) {
				case (.empty, .empty), (.failure, .failure):
					break
					
				case let (.found(expected),.found(retrieved)):
					XCTAssertEqual(expected.feed, retrieved.feed,file:file,line: line)
					XCTAssertEqual(expected.timestamp, retrieved.timestamp,file:file,line: line)
					
				default:
					XCTFail("expected to retieve \(expectedResult), got \(retrivedResult) instead",file:file,line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
