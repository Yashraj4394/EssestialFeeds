//
//  CacheFeedUseCaseTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 01/04/22.
//

import XCTest
import EssestialFeeds

class LocalFeedLoader {
	private let store: FeedStore
	init(store: FeedStore) {
		self.store = store
	}
	
	func saveItems(_ items: [FeedItem]) {
		store.deleteCacheFeed()
	}
}

//the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
class FeedStore {
	var deleteCachedFeedCallCount = 0
	
	func deleteCacheFeed(){
		deleteCachedFeedCallCount += 1
	}
}

class CacheFeedUseCaseTests: XCTestCase {
	
	//does not delete the cache feed upon creation
	func test_init_DoesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)// to decouple the applciation from framework details ,we dont let frameworks dictate the use case intrefaces (eg. adding Codable requirement or Core Data managed contexts parameters). We do so by test driving the interfaces the use case needs for its collaborators, rather than defining the interface upfront to facilitate a specific framework implementatioon.
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDeletion(){
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		let items = [uniqueItems(),uniqueItems()]
		sut.saveItems(items)
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}

	
	//MARK: - HELPERS
	func uniqueItems() -> FeedItem {
		return FeedItem(id: UUID(), description: "anyDescription", location: "anyLocation", imageURL: anyURL())
	}
	
	private func anyURL() -> URL {
		let url = URL(string: "https://www.a-url.com")!
		return url
	}
	
}
