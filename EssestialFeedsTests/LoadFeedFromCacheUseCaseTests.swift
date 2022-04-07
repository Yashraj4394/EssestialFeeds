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
		expect(sut, toCompleteWith: .failure(retrievalError), when: {
			store.completeRetrieval(with: retrievalError)
		})
	}
	
	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut,store) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrievalWithEmptyCache()
		})
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
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult:LocalFeedLoader.LoadResult, when action: () -> Void,file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			
			switch (receivedResult,expectedResult) {
					
				case let (.success(receivedImages),.success(expectedImages)):
					XCTAssertEqual(receivedImages, expectedImages, file: file,line: line)
					
				case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
					XCTAssertEqual(receivedError, expectedError, file: file,line: line)
									
				default:
					XCTFail("Expected result \(expectedResult) , got \(receivedResult) instead", file: file,line: line)
			}
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
}

