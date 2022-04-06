//
//  LocalFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

public final class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore,currentDate: @escaping() -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func saveItems(_ items: [FeedItem],completion: @escaping(Error?) -> Void) {
		store.deleteCacheFeed { [weak self] error in
			guard let self = self else {return} // if the instane is deallocated then we just return.
			
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(items,with: completion)
			}
		}
	}
	
	private func cache(_ items: [FeedItem],with completion: @escaping(Error?) -> Void) {
		store.insert(items,timestamp: currentDate()) { [weak self] error in
			guard self != nil else {return}
			
			completion(error)
		}
	}
}
