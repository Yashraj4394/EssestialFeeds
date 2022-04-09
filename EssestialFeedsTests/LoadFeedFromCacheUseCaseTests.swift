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
	
	//less than 7 days
	func test_load_deliversCachedImagesOnLessThan7daysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThan7daysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		expect(sut, toCompleteWith: .success(feed.models), when: {
			store.completeRetrieval(with: feed.local,timestamp: lessThan7daysOldTimeStamp)
		})
	}
	
	//exactly 7 days
	func test_load_deliversNoImagesOn7daysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevendaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local,timestamp: sevendaysOldTimeStamp)
		})
	}
	
	//more than 7 days
	func test_load_deliversNoImagesOn7daysOrMoreOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevendaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local,timestamp: moreThanSevendaysOldTimeStamp)
		})
	}
	
	func test_load_hasNoSideEffectsOnRetrievalError() {
		let (sut,store) = makeSUT()
		
		sut.load { _ in}
		
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsCacheOnEmptyCache() {
		let (sut,store) = makeSUT()
		
		sut.load { _ in}
		
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThan7daysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.load { _ in}
		store.completeRetrieval(with: feed.local, timestamp: lessThan7daysOldTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_deleteCacheOnSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThan7daysOldTimeStamp = fixedCurrentDate.adding(days: -7)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.load { _ in}
		store.completeRetrieval(with: feed.local, timestamp: lessThan7daysOldTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
	}
	
	func test_load_deleteCacheOnMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThan7daysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
		
		sut.load { _ in}
		store.completeRetrieval(with: feed.local, timestamp: lessThan7daysOldTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResult = [LocalFeedLoader.LoadResult]()
		sut?.load(completion: { result in
			receivedResult.append(result) })
		
		sut = nil
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertTrue(receivedResult.isEmpty)
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
	
	func uniqueImageFeed() -> (models: [FeedImage],local:[LocalFeedImage]) {
		let models = [uniqueImage(),uniqueImage()]
		let local = models.map {
			LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
		}
		
		return (models,local)
	}
	
	func uniqueImage() -> FeedImage {
		return FeedImage(id: UUID(), description: "anyDescription", location: "anyLocation", url: anyURL())
	}
	
	private func anyURL() -> URL {
		let url = URL(string: "https://www.a-url.com")!
		return url
	}
	
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
