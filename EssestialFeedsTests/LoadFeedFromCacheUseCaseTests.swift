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
	
	func test_load_requestsCacheRetrieval() {
		let (sut,store) = makeSUT()
		
		sut.load { _ in}
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_failsOnRetrievalError() {
		let (sut,store) = makeSUT()
		let retrievalError = anyNSError()
		let exp = expectation(description: "Wait for load completion")
		var receivedError: Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		store.completeRetrieval(with: retrievalError)
		wait(for: [exp], timeout: 1.0)
		XCTAssertEqual(receivedError as NSError?, retrievalError)
	}
	
	//MARK: - HELPERS -
	
	func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store,currentDate: currentDate)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return (sut,store)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 1)
	}
	
	
}

