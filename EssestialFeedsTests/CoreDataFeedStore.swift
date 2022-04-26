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
		
		perform { context in
			do {
				
				if let cache = try ManagedCache.find(in: context) {
					
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
		
		perform { context in
			do {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				
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
		
		perform { context in
			do {
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	private func perform(_ action: @escaping(NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform { action(context)}
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
	
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		
		request.returnsObjectsAsFaults = false
		
		return try context.fetch(request).first
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map(context.delete)
		
		return ManagedCache(context: context)
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
