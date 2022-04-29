//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 21/04/22.
//

import XCTest
import EssestialFeeds

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
	func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().local, Date()), sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
	}
	
	func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), sut)
		
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
}
