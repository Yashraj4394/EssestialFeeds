//
//  CodableFeedStoreTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/04/22.
//

import XCTest
import EssestialFeeds

class CodableFeedStore {
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		completion(.empty)
	}
}

class CodableFeedStoreTests: XCTestCase {
	
	func test_retreive_deliversEmptyOnEmptyCache() {
		
		let sut = CodableFeedStore()
		
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.retrieve { result in
			switch result {
				case .empty:
					break
				default:
					XCTFail("expected empty result, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retreive_hasNoSideEffectsOnEmptyCache() {
		
		let sut = CodableFeedStore()
		
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.retrieve { firstResult in
			sut.retrieve { secondResult in
				switch (firstResult,secondResult) {
					case (.empty, .empty):
						break
					default:
						XCTFail("Expected retrieving twice from empty cache to deliver same empty result , got \(firstResult) and \(secondResult) instead")
				}
				exp.fulfill()
			}
		}
		
		
		wait(for: [exp], timeout: 1.0)
	}

}
