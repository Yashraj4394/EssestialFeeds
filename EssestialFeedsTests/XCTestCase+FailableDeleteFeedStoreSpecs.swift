//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 21/04/22.
//

import XCTest
import EssestialFeeds

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
	func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
}
