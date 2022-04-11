//
//  LocalFeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

public final class FeedCachePolicy {
	private let calender = Calendar(identifier: .gregorian)
	
	var maxCacheAgeInDays: Int {
		return 7
	}
	
	func validate(_ timestamp: Date, agaist date: Date) -> Bool {
		guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {return false}
		return date < maxCacheAge
	}
}

public final class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	private let cachePolicy = FeedCachePolicy()
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
	public typealias LoadResult = LoadFeedResult
	
	public func load(completion: @escaping(LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else {return}
			switch result {
					
				case let .failure(error):
					completion(.failure(error))
					
				case let .found(feed: feed, timestamp: date) where self.cachePolicy.validate(date,agaist: self.currentDate()) :
					completion(.success(feed.toModels()))
					
				case .found,.empty:
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
					
				case let .found(feed: _, timestamp: timestamp) where !self.cachePolicy.validate(timestamp,agaist: self.currentDate()):
					self.store.deleteCacheFeed { _ in }
					
				case .empty,.found:
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
