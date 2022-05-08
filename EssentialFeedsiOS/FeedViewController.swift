//
//  FeedViewController.swift
//  EssentialFeedsiOS
//
//  Created by YashraJ Gujar on 08/05/22.
//

import UIKit
import EssestialFeeds

final public class FeedViewController: UITableViewController {
	
	private var loader: FeedLoader?
	
	//using convenience init since we dont need any custom initialization.This way we dont need to implement the UIViewController's required initialisers
	public convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	public override func viewDidLoad() {
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
