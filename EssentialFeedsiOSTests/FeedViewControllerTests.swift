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
		loader?.load(completion: { [weak self] result in
			self?.refreshControl?.endRefreshing()
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
	
	func test_userInititatedFeedReload_reloadsFeed() {
		let (sut , loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		//adding this twice as user can pull to refresh twice
		sut.simulateUserInitiatedFeedReload()
		
		XCTAssertEqual(loader.loadingCount, 2)
		
		sut.simulateUserInitiatedFeedReload()
		
		XCTAssertEqual(loader.loadingCount, 3)
	}
	
	func test_viewDidLoad_showsLoadingIndicator() {
		let (sut , _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertTrue(sut.isShowingLoadingIndicator)
	}
	
	func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
		
		let (sut , loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		loader.completeFeedLoading()
		
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	func test_userInititatedFeedReload_showsLoadingIndicator() {
		let (sut , _) = makeSUT()
		
		sut.simulateUserInitiatedFeedReload()
		
		XCTAssertTrue(sut.isShowingLoadingIndicator)
	}
	
	func test_userInititatedFeedReload_hidesLoadingIndicatorOnLoadingCompletion() {
		let (sut , loader) = makeSUT()
		
		sut.simulateUserInitiatedFeedReload()
		
		loader.completeFeedLoading()
		
		XCTAssertFalse(sut.isShowingLoadingIndicator)
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
		private var completions = [(FeedLoader.Result) -> Void]()
		var loadingCount: Int {
			return completions.count
		}
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeFeedLoading(){
			completions[0](.success([]))
		}
	}
	
}

private extension FeedViewController {
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
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
