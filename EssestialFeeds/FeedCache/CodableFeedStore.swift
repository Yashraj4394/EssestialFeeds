//
//  CodableFeedStore.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 20/04/22.
//

import Foundation

public class CodableFeedStore: FeedStore {
	
	private let storeURL: URL
	
	public init(storeURL : URL) {
		self.storeURL = storeURL
	}
	
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		
		var localFeed : [LocalFeedImage] {
			return feed.map({ $0.local })
		}
	}
	
	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		init(_ image: LocalFeedImage) {
			id = image.id
			description = image.description
			location = image.location
			url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	///background queue but by default operations run serially
	// every operation runs in a serial background queue so that we are not blocking the clients.
	private let queue = DispatchQueue(label: "\(CodableFeedStore.self)", qos: .userInitiated)
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		let storeURL = self.storeURL
		queue.async {
			guard let data = try? Data(contentsOf: storeURL) else {
				return completion(.empty)
			}
			
			do {
				let decoder = JSONDecoder()
				let cache = try decoder.decode(Cache.self, from: data)
				completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				
			}  catch {
				completion(.failure(error))
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {
		let storeURL = self.storeURL
		queue.async {
			let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
			do {
				let encode = JSONEncoder()
				let encoded = try encode.encode(cache)
				try encoded.write(to: storeURL)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		let storeURL = self.storeURL
		queue.async {
			guard FileManager.default.fileExists(atPath: storeURL.path) else {
				return completion(nil)
			}
			do {
				try FileManager.default.removeItem(at: storeURL)
			} catch {
				completion(error)
			}
		}
	}
}
