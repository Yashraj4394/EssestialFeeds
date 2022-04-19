//
//  CodableFeedStoreTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 19/04/22.
//

import XCTest
import EssestialFeeds

class CodableFeedStore {
	
	private struct Cache: Codable {
		let feed: [LocalFeedImage]
		let timestamp: Date
	}
	
	private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
		return completion(.empty)
		}
		
		let decoder = JSONDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.feed, timestamp: cache.timestamp))
	}
	
	func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping FeedStore.InsertionCompletion) {
		
		let encode = JSONEncoder()
		let encoded = try! encode.encode(Cache(feed: feed, timestamp: timestamp))
		try! encoded.write(to: storeURL)
		completion(nil)
	}
}

class CodableFeedStoreTests: XCTestCase {
	
	//called before running each test
	override func setUp() {
		super.setUp()
		print("Cache location :",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString)
		
		// removing data because if we have a crash in the test or we are using a breakpoint and stopping the next flow, then teardown is not called. Hence there will be artifacts from previous tests eg. the cache data
		// (*** Tests are run randomly and not one after after ***)
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
		
	}
	//called after each test is completed
	override func tearDown() {
		super.tearDown()
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}
	
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
	
	func test_retreiveAfterInsertingToEmptyCache_deliversInsertedValues() {
		
		let sut = CodableFeedStore()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let exp = expectation(description: "wait for cache retrieval")
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError,"expected feed to be insterted successfully")
			
			sut.retrieve { retrievedResult in
				switch retrievedResult {
					case let .found(feed: receivedFeed, timestamp: receivedTimestamp):
					XCTAssertEqual(receivedFeed, feed)
					XCTAssertEqual(receivedTimestamp, timestamp)
						
					default:
						XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp) , got \(retrievedResult) instead")
				}
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 1.0)
	}

}
