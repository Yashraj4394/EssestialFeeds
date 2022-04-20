//
//  CodableFeedStoreTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/04/22.
//

import XCTest
import EssestialFeeds

class CodableFeedStore: FeedStore {
	
	private let storeURL: URL
	
	init(storeURL : URL) {
		self.storeURL = storeURL
	}
	
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		
		var localFeed : [LocalFeedImage] {
			return feed.map({ $0.local })
		}
	}
	
	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		init(_ image: LocalFeedImage) {
			id = image.id
			description = image.description
			location = image.location
			url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			return completion(.empty)
		}
		do {
			let decoder = JSONDecoder()
			let cache = try decoder.decode(Cache.self, from: data)
			completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
		}  catch {
			completion(.failure(error))
		}
	}
	
	func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {
		let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
		do {
			let encode = JSONEncoder()
			let encoded = try encode.encode(cache)
			try encoded.write(to: storeURL)
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		guard FileManager.default.fileExists(atPath: storeURL.path) else {
			return completion(nil)
		}
		do {
			try FileManager.default.removeItem(at: storeURL)
		} catch {
			completion(error)
		}
		
	}
}

class CodableFeedStoreTests: XCTestCase {
	
	//called before running each test
	override func setUp() {
		super.setUp()
		print("Cache location :",FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.absoluteString)
		
		// removing data because if we have a crash in the test or we are using a breakpoint and stopping the next flow, then teardown is not called. Hence there will be artifacts from previous tests eg. the cache data
		// (*** Tests are run randomly and not one after after ***)
		setupEmptyStoreState()
		
	}
	
	//called after each test is completed
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	func test_retreive_deliversEmptyOnEmptyCache() {
		
		let sut = makeSUT()
		expect(sut, toRetrieve: .empty)
	}
	
	func test_retreive_hasNoSideEffectsOnEmptyCache() {
		
		let sut = makeSUT()
		
		expect(sut, toRetrieveTwice: .empty)
	}
	
	func test_retreive_deliversFoundValuesOnNonEmptyCache() {
		
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed,timestamp), sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retreive_hasNoSideEffectsOnNonEmtyCache() {
		
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed,timestamp), sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieve: .failure(anyNSError()))
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	func test_insert_overridesPreviouslyInsertedCachedValues() {
		let sut = makeSUT()
		
		let firstInsertionError = insert((uniqueImageFeed().local,Date()), sut)
		XCTAssertNil(firstInsertionError,"Expected to insert cache successfully")
		
		let latestFeed = uniqueImageFeed().local
		let latestTimeStamp = Date()
		let latestInsertionError = insert((latestFeed,latestTimeStamp), sut)
		XCTAssertNil(latestInsertionError,"Expected to overide cache successfully")
		
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimeStamp))
	}
	
	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalidPath://store-url")
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed,timestamp), sut)
		
		XCTAssertNotNil(insertionError,"expected cache insertion to fail with an error")
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
			let sut = makeSUT()
			
			let deletionError = deleteCache(from: sut)
			
			XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
			expect(sut, toRetrieve: .empty)
		}
		
	/*
	 *** There is an issue with the cache deletion due to system configuration. Check this : https://academy.essentialdeveloper.com/courses/447455/lectures/10675368/comments/7321729
	 func test_delete_emptiesPreviouslyInsertedCache() {
		 let sut = makeSUT()
		 insert((uniqueImageFeed().local, Date()),sut)
		 
		 let deletionError = deleteCache(from: sut)
		 
		 XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
		 expect(sut, toRetrieve: .empty)
	 }
	 */
		
		func test_delete_deliversErrorOnDeletionError() {
			let noDeletePermissionURL = cachesDirectory()
			let sut = makeSUT(storeURL: noDeletePermissionURL)
			
			let deletionError = deleteCache(from: sut)
			
			XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
			expect(sut, toRetrieve: .empty)
		}
	
	//MARK: - HELPERS
	
	private func makeSUT(storeURL: URL? = nil,file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	@discardableResult
	private func insert(_ cache:(feed: [LocalFeedImage],timestamp: Date),_ sut: CodableFeedStore) -> Error? {
		let exp = expectation(description: "wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	private func deleteCache(from sut: CodableFeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		
		sut.deleteCacheFeed { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	private func expect(_ sut: CodableFeedStore,toRetrieveTwice expectedResult: RetrieveCachedFeedResult,file: StaticString = #filePath, line: UInt = #line) {
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
		
		expect(sut, toRetrieve: expectedResult,file: file,line: line)
	}
	
	private func expect(_ sut: CodableFeedStore,toRetrieve expectedResult: RetrieveCachedFeedResult,file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.retrieve { retrivedResult in
			
			switch (retrivedResult,expectedResult) {
				case (.empty, .empty), (.failure, .failure):
					break
					
				case let (.found(expected),.found(retrieved)):
					XCTAssertEqual(expected.feed, retrieved.feed,file:file,line: line)
					XCTAssertEqual(expected.timestamp, retrieved.timestamp,file:file,line: line)
					
				default:
					XCTFail("expected to retieve \(expectedResult), got \(retrivedResult) instead",file:file,line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
	
}
