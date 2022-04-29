//
//  LocalFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation
/*
 *** Core business logic ***
 */

public final class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore,currentDate: @escaping() -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
}

extension LocalFeedLoader {
	public typealias SaveResult = Error?
	
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

extension LocalFeedLoader : FeedLoader {
	public typealias LoadResult = FeedLoader.Result
	
	public func load(completion: @escaping(LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else {return}
			switch result {
					
				case let .failure(error):
					completion(.failure(error))
					
				
				case let .success(.found(feed: feed, timestamp: date)) where FeedCachePolicy.validate(date,agaist: self.currentDate()) :
					completion(.success(feed.toModels()))
					
				case .success(.found),.success(.empty):
					completion(.success([]))
			}
		}
	}
}

extension LocalFeedLoader {
	public func validateCache() {
		store.retrieve { [weak self] result in
			guard let self = self else {return}
			switch result {
					
				case .failure:
					self.store.deleteCacheFeed { _ in }
					
				case let .success(.found(feed: _, timestamp: timestamp)) where !FeedCachePolicy.validate(timestamp,agaist: self.currentDate()):
					self.store.deleteCacheFeed { _ in }
					
				case .success(.empty),.success(.found):
					break
			}
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

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		return map{
			FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
		}
	}
}
