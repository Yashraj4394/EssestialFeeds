//
//  FeedViewControllerTests.swift
//  EssentialFeedsiOSTests
//
//  Created by YashraJ Gujar on 07/05/22.
//

import XCTest
import UIKit

class FeedViewController: UIViewController {
	
	private var loader: FeedViewControllerTests.LoaderSpy?
	
	//using convenience init since we dont need any custom initialization.This way we dont need to implement the UIViewController's required initialisers
	convenience init(loader: FeedViewControllerTests.LoaderSpy) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loader?.load()
	}
	
}

final class FeedViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadFeed(){
		let loader = LoaderSpy()
		_ = FeedViewController(loader:loader)
		
		XCTAssertEqual(loader.loadingCount, 0)
	}
	
	func test_viewDidLoad_loadsFeed(){
		let loader = LoaderSpy()
		let sut = FeedViewController(loader:loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadingCount, 1)
	}
	
	//MARK: - HELPERS
	
	class LoaderSpy {
		private(set) var loadingCount = 0
		
		func load(){
		loadingCount += 1
		}
	}
	
}
