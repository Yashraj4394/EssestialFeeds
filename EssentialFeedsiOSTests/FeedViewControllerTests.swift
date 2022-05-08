//
//  FeedViewControllerTests.swift
//  EssentialFeedsiOSTests
//
//  Created by YashraJ Gujar on 07/05/22.
//

import XCTest
import UIKit
import EssestialFeeds

class FeedViewController: UITableViewController {
	
	private var loader: FeedLoader?
	
	//using convenience init since we dont need any custom initialization.This way we dont need to implement the UIViewController's required initialisers
	convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		refreshControl?.beginRefreshing()
		load()
	}
	
	@objc private func load(){
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
	
	func test_pullToRefresh_loadsFeed() {
		let (sut , loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		//adding this twice as user can pull to refresh twice
		sut.refreshControl?.simulatePullToRefresh()
		
		XCTAssertEqual(loader.loadingCount, 2)
		
		sut.refreshControl?.simulatePullToRefresh()
		
		XCTAssertEqual(loader.loadingCount, 3)
	}
	
	func test_viewDidLoad_showsLoadingIndicator() {
		let (sut , _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
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

private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach({ target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ value in
				(target as NSObject).perform(Selector(value))
			})
		})
	}
}
