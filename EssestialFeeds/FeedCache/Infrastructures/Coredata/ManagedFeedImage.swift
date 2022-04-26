//
//  ManagedFeedImage.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 26/04/22.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
	internal var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
	
	internal static func images(from localFeed: [LocalFeedImage],in context: NSManagedObjectContext) -> NSOrderedSet {
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
