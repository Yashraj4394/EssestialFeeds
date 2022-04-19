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

}
