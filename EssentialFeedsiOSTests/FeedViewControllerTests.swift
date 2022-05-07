//
//  FeedViewControllerTests.swift
//  EssentialFeedsiOSTests
//
//  Created by YashraJ Gujar on 07/05/22.
//

import XCTest

class FeedViewController {
	init(loader: FeedViewControllerTests.LoaderSpy) {
		
	}
}

final class FeedViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadFeed(){
		let loader = LoaderSpy()
		_ = FeedViewController(loader:loader)
		
		XCTAssertEqual(loader.loadingCount, 0)
	}
	
	//MARK: - HELPERS
	
	class LoaderSpy {
		private(set) var loadingCount = 0
	}
}
