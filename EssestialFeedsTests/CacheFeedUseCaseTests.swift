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
	
	func saveItems(_ items: [FeedItem],completion: @escaping(Error?) -> Void) {
		store.deleteCacheFeed { [unowned self] error in
			completion(error)
			if error == nil {
				self.store.insert(items,timestamp: self.currentDate())
			}
		}
	}
}

//the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	
	private var deletionCompletion = [DeletionCompletion]()
	
	enum ReceivedMessages: Equatable {
		case deleteCachedFeed
		case insert([FeedItem],Date)
	}
	
	private(set) var receivedMessages = [ReceivedMessages]()
	
	func deleteCacheFeed(completion: @escaping DeletionCompletion){
		deletionCompletion.append(completion)
		receivedMessages.append(.deleteCachedFeed)
	}
	
	func completeDeletion(with error:Error, at index: Int = 0) {
		deletionCompletion[index](error)
	}
	
	func completeSuccessfully(at index: Int = 0) {
		deletionCompletion[index](nil)
	}
	
	func insert(_ items: [FeedItem],timestamp: Date) {
		receivedMessages.append(.insert(items, timestamp))
	}
}

class CacheFeedUseCaseTests: XCTestCase {
	
	//does not delete cache upon creation
	func test_init_DoesNotMessageStoreUponCreation() {
		let (_,store) = makeSUT()
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_save_requestsCacheDeletion(){
		let (sut,store) = makeSUT()
		let items = [uniqueItems(),uniqueItems()]
		sut.saveItems(items) { _ in }
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError(){
		let (sut,store) = makeSUT()
		let items = [uniqueItems(),uniqueItems()]
		let deletionError = anyNSError()
		sut.saveItems(items) { _ in }
		store.completeDeletion(with: deletionError)
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_requestCacheInsertionWithTimeStampOnSuccessfulDeletion(){
		//The current date/time is not a pure function(every time you create a date instance , it has a different value- current date/time). Instead of letting the Use Case produce the current date via impure Date.init() function directly, we can move this responsibility to a collaborator(a simple closure in this case) and inject it as a dependency. Then , we can easily control current date/time during tests.
		let timestamp = Date()
		let (sut,store) = makeSUT(currentDate: { timestamp })
		let items = [uniqueItems(),uniqueItems()]
		
		sut.saveItems(items) { _ in }
		store.completeSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed,.insert(items, timestamp)])
	}
	
	func test_save_failsOnDeletionError(){
		let (sut,store) = makeSUT()
		
		let items = [uniqueItems(),uniqueItems()]
		
		let deletionError = anyNSError()
		
		var receivedError: Error?
		
		let exp = expectation(description: "wait for save completion")
		sut.saveItems(items) { error in
			receivedError = error
			exp.fulfill()
		}
		store.completeDeletion(with: deletionError)
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, deletionError)
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
