//
//  FeedStore.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	
	typealias InsertionCompletion = (Error?) -> Void
	func insert(_ items: [LocalFeedItem],timestamp: Date,completion: @escaping InsertionCompletion)
	
}

public struct LocalFeedItem: Equatable {
	//making constants public
	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL
	
	//struct has a default initialiazer but that is internal which is not accessible outside this module. So we create a public initializer
	public init(id: UUID,description: String?,location: String?,imageURL: URL){
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}
}
