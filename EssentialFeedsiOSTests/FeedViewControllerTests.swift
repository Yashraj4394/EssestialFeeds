//
//  FeedViewControllerTests.swift
//  EssentialFeedsiOSTests
//
//  Created by YashraJ Gujar on 07/05/22.
//

import XCTest
import UIKit
import EssestialFeeds

class FeedViewController: UIViewController {
	
	private var loader: FeedLoader?
	
	//using convenience init since we dont need any custom initialization.This way we dont need to implement the UIViewController's required initialisers
	convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loader?.load(completion: { result in
			
		})
	}
	
}

final class FeedViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadFeed(){
		let (_ , loader) = makeSUT()
		
		XCTAssertEqual(loader.loadingCount, 0)
	}
	
	func test_viewDidLoad_loadsFeed(){
		let (sut , loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadingCount, 1)
	}
	
	//MARK: - HELPERS
	
	func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController,loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedViewController(loader: loader)
		trackForMemoryLeaks(loader,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		
		return (sut,loader)
	}
	
	class LoaderSpy: FeedLoader {
		
		private(set) var loadingCount = 0
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			loadingCount += 1
		}
	}
	
}
