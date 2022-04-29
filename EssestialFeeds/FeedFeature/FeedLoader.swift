//
//  FeedLoader.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 19/03/22.
//

import Foundation


public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage],Error>
	
	func load(completion: @escaping (Result) -> Void)
}
