//
//  ManagedCache.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 26/04/22.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache : NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
	
	internal var locaFeed: [LocalFeedImage] {
		return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
	
	internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		
		request.returnsObjectsAsFaults = false
		
		return try context.fetch(request).first
	}
	
	internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map(context.delete)
		
		return ManagedCache(context: context)
	}
}
