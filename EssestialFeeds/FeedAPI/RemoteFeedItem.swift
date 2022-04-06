//
//  RemoteFeedItem.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 06/04/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let image: URL
}
