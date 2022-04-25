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
		
	}
	
	func test_retreive_deliversFoundValuesOnNonEmptyCache() {
		
	}
	
	func test_retreive_hasNoSideEffectsOnNonEmtyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		
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
		let sut = CoreDataFeedStore()
		trackForMemoryLeaks(sut,file: file,line: line)
		return sut
	}
}
