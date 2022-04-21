//
//  FeedStoreSpecs.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 21/04/22.
//

import Foundation

protocol FeedStoreSpecs {
	func test_retreive_deliversEmptyOnEmptyCache()
	func test_retreive_hasNoSideEffectsOnEmptyCache()
	func test_retreive_deliversFoundValuesOnNonEmptyCache()
	func test_retreive_hasNoSideEffectsOnNonEmtyCache()
	
	func test_insert_deliversNoErrorOnEmptyCache()
	func test_insert_deliversNoErrorOnNonEmptyCache()
	func test_insert_overridesPreviouslyInsertedCachedValues()
	
	func test_delete_deliversNoErrorOnEmptyCache()
	func test_delete_hasNoSideEffectsOnEmptyCache()
	func test_delete_deliversNoErrorOnNonEmptyCache()
	func test_delete_emptiesPreviouslyInsertedCache()
	
	func test_storeSideEffects_runSerially()
}


//separating error cases as they were not mandatory (check LocalFeedImplementation file)
protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
	func test_retrieve_deliversFailureOnRetrievalError()
	func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
	func test_insert_deliversErrorOnInsertionError()
	func test_insert_hasNoSideEffectsInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
	func test_delete_deliversErrorOnDeletionError()
	func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
