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
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader?.load(completion: { [weak self] result in
			self?.refreshControl?.endRefreshing()
		})
	}
	
}

final class FeedViewControllerTests: XCTestCase {
	
	func test_loadFeedActions_requestsFeedFromLoader(){
		let (sut , loader) = makeSUT()
		
		XCTAssertEqual(loader.loadingCount, 0, "expected no loading requests before view is loaded")
	
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadingCount, 1,"expected a loading request once when view is loaded")
	
	//adding this twice as user can pull to refresh twice
		sut.simulateUserInitiatedFeedReload()
		
		XCTAssertEqual(loader.loadingCount, 2,"Expected another loading request once user initaites a load")
		
		sut.simulateUserInitiatedFeedReload()
		
		XCTAssertEqual(loader.loadingCount, 3,"Expected third loading request once user initaites a load")
	}
	
	func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
		let (sut , loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator,"expected loading indicator once view is loaded")
	
		loader.completeFeedLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator,"expected no loading indicator once view is loaded")
	
		sut.simulateUserInitiatedFeedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator,"expected loading indicator once user initaites a reload")
		
		loader.completeFeedLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator,"expected no loading indicator once user initaited load is completed")
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
		
		func completeFeedLoading(at index: Int){
			completions[index](.success([]))
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
