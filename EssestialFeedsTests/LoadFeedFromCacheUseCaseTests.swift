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
		
		sut.load()
		
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

