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
	var insertCallCount = 0
	
	func deleteCacheFeed(){
		deleteCachedFeedCallCount += 1
	}
	
	func completeDeletion(with error:Error, at index: Int = 0) {
		
	}
}

class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_DoesNotDeleteCacheUponCreation() {
		let (_,store) = makeSUT()
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDeletion(){
		let (sut,store) = makeSUT()
		let items = [uniqueItems(),uniqueItems()]
		sut.saveItems(items)
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError(){
		let (sut,store) = makeSUT()
		let items = [uniqueItems(),uniqueItems()]
		let deletionError = anyNSError()
		sut.saveItems(items)
		store.completeDeletion(with: deletionError)
		XCTAssertEqual(store.insertCallCount, 0)
	}
	
	//MARK: - HELPERS
	func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return (sut,store)
	}
	
	func uniqueItems() -> FeedItem {
		return FeedItem(id: UUID(), description: "anyDescription", location: "anyLocation", imageURL: anyURL())
	}
	
	private func anyURL() -> URL {
		let url = URL(string: "https://www.a-url.com")!
		return url
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 1)
	}
}
