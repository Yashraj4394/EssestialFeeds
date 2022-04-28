//
//  EssestialFeedsCacheIntegrationTests.swift
//  EssestialFeedsCacheIntegrationTests
//
//  Created by YashraJ Gujar on 28/04/22.
//

import XCTest
import EssestialFeeds

///Idea is to integrate all the cache model objects and see how they behave in collaboration with real instances of production types.
class EssestialFeedsCacheIntegrationTests: XCTestCase {
	
	//called before running each test
	override func setUp() {
		super.setUp()
		// removing data because if we have a crash in the test or we are using a breakpoint and stopping the next flow, then teardown is not called. Hence there will be artifacts from previous tests eg. the cache data
		// (*** Tests are run randomly and not one after after ***)
		setupEmptyStoreState()
	}
	
	//called after each test is completed
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	func test_load_deliversNoItemsOnEmptyCache(){
		let sut = makeSUT()
		
		let expect = expectation(description: "wait for load completion")
		
		sut.load { result in
			switch result {
				case let .success(imageFeed):
					XCTAssertEqual(imageFeed, [], "Expected empty feed")
				case let .failure(error):
					XCTFail("Expetcted successful feed result, got \(error) instead")
			}
			expect.fulfill()
		}
		
		wait(for: [expect], timeout: 1.0)
	}
	
	func test_load_deliversItemsSavedOnSeparateInstances(){
		let sutToPerformSave = makeSUT()
		let sutToPerformLoad = makeSUT()
		
		let saveExp = expectation(description: "Wait for save to complete")
		let feed = uniqueImageFeed().models
		sutToPerformSave.saveItems(feed) { saveError in
			XCTAssertNil(saveError,"Exoected to save feed successfully")
			saveExp.fulfill()
		}
		wait(for: [saveExp], timeout: 1.0)
		
		let loadExp = expectation(description: "Wait for load to complete")
		sutToPerformLoad.load { loadResult in
			switch loadResult {
				case let .success(imageFeed):
					XCTAssertEqual(feed, imageFeed)
				case let .failure(error):
					XCTFail("Expected successful feed result, got \(error) instead")
			}
			loadExp.fulfill()
		}
		
		wait(for: [loadExp], timeout: 1.0)
		
	}
	
	
	//MARK:- HELPERS
	func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = testSpecificStoreURL()
		let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		let sut = LocalFeedLoader(store: store, currentDate: Date.init)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return sut
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
}
