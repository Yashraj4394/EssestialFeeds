//
//  FeedItem.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 19/03/22.
//

import Foundation

public struct FeedItem: Equatable {
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

extension FeedItem: Decodable {
	private enum CodingKeys: String,CodingKey {
		case id
		case description
		case location
		case imageURL = "image"
	}
}
