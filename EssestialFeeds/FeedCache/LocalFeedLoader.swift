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
	public typealias SaveResult = Error?
	
	public init(store: FeedStore,currentDate: @escaping() -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func saveItems(_ feed: [FeedImage],completion: @escaping(SaveResult) -> Void) {
		store.deleteCacheFeed { [weak self] error in
			guard let self = self else {return} // if the instane is deallocated then we just return.
			
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed,with: completion)
			}
		}
	}
	
	private func cache(_ feed: [FeedImage],with completion: @escaping(SaveResult) -> Void) {
		store.insert(feed.toLocal(),timestamp: currentDate()) { [weak self] error in
			guard self != nil else {return}
			
			completion(error)
		}
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map{
			LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
		}
	}
}