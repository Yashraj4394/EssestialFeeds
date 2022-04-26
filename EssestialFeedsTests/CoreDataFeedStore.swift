//
//  CoreDataFeedStore.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 25/04/22.
//

import EssestialFeeds
import CoreData

public final class CoreDataFeedStore: FeedStore {
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL,bundle:Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore",url: storeURL, in: bundle)
		
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				
				let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				
				request.returnsObjectsAsFaults = false
				
				if let cache = try context.fetch(request).first {
					
					completion(.found(feed: cache.locaFeed, timestamp: cache.timestamp))
					
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		
		context.perform {
			do {
				let managedCache = ManagedCache(context:context)
				
				managedCache.timestamp = timestamp
				
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				
				try context.save()
				
				completion(nil)
				
			} catch {
				completion(error)
			}
		}
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		
	}
	
}

private extension NSPersistentContainer {
	
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	static func load(modelName name:String,url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}
		
		let description = NSPersistentStoreDescription(url: url)
		
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		var loadingError: Swift.Error?
		container.loadPersistentStores { loadingError = $1 }
		
		try loadingError.map({
			throw LoadingError.failedToLoadPersistentStores($0)
		})
		
		return container
	}
}

private extension NSManagedObjectModel {
	
	static func with(name: String,in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle.url(
			forResource: name,
			withExtension: "momd").flatMap({NSManagedObjectModel(contentsOf: $0)})
	}
}

@objc(ManagedCache)
private class ManagedCache : NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
	
	var locaFeed: [LocalFeedImage] {
		return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
	
	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
	
	static func images(from localFeed: [LocalFeedImage],in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: localFeed.map({ local in
			
			let managedImage = ManagedFeedImage(context:context)
			managedImage.id = local.id
			managedImage.imageDescription = local.description
			managedImage.location = local.location
			managedImage.url = local.url
			return managedImage
			
		})
		)
	}
}
