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
	public typealias SaveResult = Result<Void,Error>
	
	public func saveItems(_ feed: [FeedImage],completion: @escaping(SaveResult) -> Void) {
		store.deleteCacheFeed { [weak self] deletionResult in
			guard let self = self else {return} // if the instane is deallocated then we just return.
			switch deletionResult {
				case .success:
					self.cache(feed,with: completion)
				case .failure(let error):
					completion(.failure(error))
			}
		}
	}
	
	private func cache(_ feed: [FeedImage],with completion: @escaping(SaveResult) -> Void) {
		store.insert(feed.toLocal(),timestamp: currentDate()) { [weak self] instertionError in
			guard self != nil else {return}
			completion(instertionError)
			
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
					
				case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp,agaist: self.currentDate()) :
					completion(.success(cache.feed.toModels()))
					
				case .success(.some),.success(.none):
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
					
				case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp,agaist: self.currentDate()):
					self.store.deleteCacheFeed { _ in }
					
				case .success(.none),.success(.some):
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
