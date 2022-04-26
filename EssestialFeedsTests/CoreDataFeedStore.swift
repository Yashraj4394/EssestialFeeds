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
	
	public init(bundle:Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		
	}
	
}

private extension NSPersistentContainer {

	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}

	static func load(modelName name:String,in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}
		let container = NSPersistentContainer(name: name, managedObjectModel: model)

		var loadingError: Swift.Error?
		container.loadPersistentStores { loadingError = $1 }

		try loadingError.map({
			throw LoadingError.failedToLoadPersistentStores($0)
		})

		return container
	}
}
//
private extension NSManagedObjectModel {

	static func with(name: String,in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle.url(
			forResource: name,
			withExtension: "momd").flatMap({NSManagedObjectModel(contentsOf: $0)})
	}
}

private class ManagedCache : NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}
