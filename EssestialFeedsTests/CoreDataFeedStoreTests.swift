//
//  CoreDataFeedStoreTests.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/04/22.
//

import XCTest
import EssestialFeeds

class CoreDataFeedStoreTests: XCTestCase,FeedStoreSpecs {
	
	func test_retreive_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retreive_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retreive_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retreive_hasNoSideEffectsOnNonEmtyCache() {
		let sut = makeSUT()
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCachedValues() {
		
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() {
		
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		
	}
	
	func test_storeSideEffects_runSerially() {
		
	}
	
		//MARK: -  HELPERS
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataFeedStore(storeURL:storeURL, bundle: storeBundle)
		trackForMemoryLeaks(sut,file: file,line: line)
		return sut
	}
}
