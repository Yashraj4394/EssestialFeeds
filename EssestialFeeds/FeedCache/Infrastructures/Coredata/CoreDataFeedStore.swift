//
//  CoreDataFeedStore.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/04/22.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL,bundle:Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore",url: storeURL, in: bundle)
		
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		perform { context in
			//caching throws error. So there is no need for catch block as it will be automatically wraps it in a failure case of Result type.//Also there is no need to wrap completion in success/failure type. Catching automatically wraps data in success/failure case
			/*
			 
			 // *** A ***
			 completion(Result(catching: {
				 
				 // *** OPTION 1 ***
					if let cache = try ManagedCache.find(in: context) {
						return (.some(CacheFeed(feed: cache.locaFeed, timestamp: cache.timestamp)))

					} else {
						return (.none)
					}

					// *** OPTION 2 ***
					
					try ManagedCache.find(in: context).map({ cache in
						return CacheFeed(feed: cache.locaFeed, timestamp: cache.timestamp)
					})
			 }))
		*/
			 
			// **** B *****
			completion(Result {
				try ManagedCache.find(in: context).map {
					return CacheFeed(feed: $0.locaFeed, timestamp: $0.timestamp)
				}
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
		perform { context in
			
			completion(Result {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				
				managedCache.timestamp = timestamp
				
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				
				try context.save()
			})
			
		}
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		
		perform { context in
			completion(Result {
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
			})
		}
	}
	
	private func perform(_ action: @escaping(NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform { action(context)}
	}
}
