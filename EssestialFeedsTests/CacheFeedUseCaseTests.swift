//
//  CacheFeedUseCaseTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 01/04/22.
//

import XCTest

class LocalFeedLoader {
	init(store: FeedStore) {
		
	}
}

class FeedStore {
	var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
	
	//does not delete the cache feed upon creation
	func test_init_DoesNotDeleteCacheUponCreation(){
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}

}
