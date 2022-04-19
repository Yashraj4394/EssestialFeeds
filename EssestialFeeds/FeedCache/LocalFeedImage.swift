//
//  LocalFeedItem.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

public struct LocalFeedImage: Equatable {
	//making constants public
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
	
	//struct has a default initialiazer but that is internal which is not accessible outside this module. So we create a public initializer
	public init(id: UUID,description: String?,location: String?,url: URL){
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
