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
	private let currentDate: () -> Date
	init(store: FeedStore,currentDate: @escaping() -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	func saveItems(_ items: [FeedItem]) {
		store.deleteCacheFeed { [unowned self] error in
			if error == nil {
				self.store.insert(items,timestamp: self.currentDate())
			}
		}
	}
}

//the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	
	var deleteCachedFeedCallCount = 0
	
	var insertCallCount = 0
	
	private var deletionCompletion = [DeletionCompletion]()
	
	var insertions = [(items: [FeedItem],timestamp:Date)]()
	
	func deleteCacheFeed(completion: @escaping DeletionCompletion){
		deleteCachedFeedCallCount += 1
		deletionCompletion.append(completion)
	}
	
	func completeDeletion(with error:Error, at index: Int = 0) {
		deletionCompletion[index](error)
	}
	
	func completeSuccessfully(at index: Int = 0) {
		deletionCompletion[index](nil)
	}
	
	func insert(_ items: [FeedItem],timestamp: Date) {
		insertCallCount += 1
		insertions.append((items,timestamp))
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
	
	func test_save_requestCacheInsertionOnSuccessfulDeletion(){
		let (sut,store) = makeSUT()
		let items = [uniqueItems(),uniqueItems()]
		
		sut.saveItems(items)
		store.completeSuccessfully()
		XCTAssertEqual(store.insertCallCount, 1)
	}
	
	func test_save_requestCacheInsertionWithTimeStampOnSuccessfulDeletion(){
		//The current date/time is not a pure function(every time you create a date instance , it has a different value- current date/time). Instead of letting the Use Case produce the current date via impure Date.init() function directly, we can move this responsibility to a collaborator(a simple closure in this case) and inject it as a dependency. Then , we can easily control current date/time during tests.
		let timestamp = Date()
		let (sut,store) = makeSUT(currentDate: { timestamp })
		let items = [uniqueItems(),uniqueItems()]
		
		sut.saveItems(items)
		store.completeSuccessfully()
		XCTAssertEqual(store.insertions.count, 1)
		XCTAssertEqual(store.insertions.first?.items, items)
		XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
	}
	
	//MARK: - HELPERS
	func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store,currentDate: currentDate)
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
