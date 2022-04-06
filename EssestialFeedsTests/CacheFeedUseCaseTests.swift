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
		store.deleteCacheFeed { [weak self] error in
			guard let self = self else {return} // if the instane is deallocated then we just return.
			if error == nil {
				self.store.insert(items,timestamp: self.currentDate()) { [weak self] error in
					guard self != nil else {return}
					completion(error)
				}
			} else {
				completion(error)
			}
		}
	}
}

protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	
	typealias InsertionCompletion = (Error?) -> Void
	func insert(_ items: [FeedItem],timestamp: Date,completion: @escaping InsertionCompletion)
	
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
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed,.insert(items, timestamp)])
	}
	
	func test_save_failsOnDeletionError(){
		//		let (sut,store) = makeSUT()
		//
		//		let items = [uniqueItems(),uniqueItems()]
		//
		//		let deletionError = anyNSError()
		//
		//		var receivedError: Error?
		//
		//		let exp = expectation(description: "wait for save completion")
		//		sut.saveItems(items) { error in
		//			receivedError = error
		//			exp.fulfill()
		//		}
		//		store.completeDeletion(with: deletionError)
		//		wait(for: [exp], timeout: 1.0)
		//
		//		XCTAssertEqual(receivedError as NSError?, deletionError)
		
		let (sut,store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}
	
	func test_save_failsOnInsertionError(){
		//		let (sut,store) = makeSUT()
		//
		//		let items = [uniqueItems(),uniqueItems()]
		//
		//		let insertionError = anyNSError()
		//
		//		var receivedError: Error?
		//
		//		let exp = expectation(description: "wait for save completion")
		//		sut.saveItems(items) { error in
		//			receivedError = error
		//			exp.fulfill()
		//		}
		//		store.completeDeletionSuccessfully()
		//		store.completeInsertion(with: insertionError)
		//		wait(for: [exp], timeout: 1.0)
		//
		//		XCTAssertEqual(receivedError as NSError?, insertionError)
		
		let (sut,store) = makeSUT()
		let insertionError = anyNSError()
		
		expect(sut, toCompleteWithError: insertionError) {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		}
	}
	
	func test_save_succeedsOnSuccessfulCacheInsertion(){
		//		let (sut,store) = makeSUT()
		
		//		let items = [uniqueItems(),uniqueItems()]
		
		//		var receivedError: Error?
		//
		//		let exp = expectation(description: "wait for save completion")
		//		sut.saveItems(items) { error in
		//			receivedError = error
		//			exp.fulfill()
		//		}
		//		store.completeDeletionSuccessfully()
		//		store.completeInsertionSuccessfuly()
		//		wait(for: [exp], timeout: 1.0)
		//
		//		XCTAssertNil(receivedError)
		
		let (sut,store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil) {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfuly()
		}
	}
	
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		var receivedError = [Error?]()
		sut?.saveItems([uniqueItems()], completion: { error in
			receivedError.append(error)
		})
		
		sut = nil
		
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedError.isEmpty)
	}
	
	func test_save_doesNotDeliverInsetionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		var receivedError = [Error?]()
		sut?.saveItems([uniqueItems()], completion: { error in
			receivedError.append(error)
		})
		
		store.completeDeletionSuccessfully()
		
		sut = nil
		
		store.completeInsertion(with: anyNSError())
		
		XCTAssertTrue(receivedError.isEmpty)
	}
	
	//MARK: - HELPERS -
	
	func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store,currentDate: currentDate)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return (sut,store)
	}
	
	private func expect(_ sut: LocalFeedLoader,toCompleteWithError expectedError: NSError?, when action: () -> Void,file: StaticString = #filePath, line: UInt = #line) {
		var receivedError: Error?
		
		let exp = expectation(description: "wait for save completion")
		sut.saveItems([uniqueItems()]) { error in
			receivedError = error
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError,file:file,line: line)
	}
	
	 //the feedstore is a helper class representing a framework side to help us define the abstract interface the use case needs for its collaborator , making sure not to leak framework details into the use case.
	 class FeedStoreSpy: FeedStore {
	 
	 private var deletionCompletions = [DeletionCompletion]()
	 
	 private var insertionCompletions = [InsertionCompletion]()
	 
	 enum ReceivedMessages: Equatable {
		 case deleteCachedFeed
		 case insert([FeedItem],Date)
	 }
	 
	 private(set) var receivedMessages = [ReceivedMessages]()
	 
	 func deleteCacheFeed(completion: @escaping DeletionCompletion){
		 deletionCompletions.append(completion)
		 receivedMessages.append(.deleteCachedFeed)
	 }
	 
	 func completeDeletion(with error:Error, at index: Int = 0) {
		 deletionCompletions[index](error)
	 }
	 
	 func completeDeletionSuccessfully(at index: Int = 0) {
		 deletionCompletions[index](nil)
	 }
	 
	 func insert(_ items: [FeedItem],timestamp: Date,completion: @escaping InsertionCompletion) {
		 receivedMessages.append(.insert(items, timestamp))
		 insertionCompletions.append(completion)
	 }
	 
	 func completeInsertion(with error: Error,at index: Int = 0) {
		 insertionCompletions[index](error)
	 }
	 
	 func completeInsertionSuccessfuly(at index: Int = 0){
		 insertionCompletions[index](nil)
	 }
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
