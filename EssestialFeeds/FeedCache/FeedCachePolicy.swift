//
//  FeedCachePolicy.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 11/04/22.
//

import Foundation

internal final class FeedCachePolicy {
	
	private init(){}
	
	private static let calender = Calendar(identifier: .gregorian)
	
	static var maxCacheAgeInDays: Int {
		return 7
	}
	
	internal static func validate(_ timestamp: Date, agaist date: Date) -> Bool {
		guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {return false}
		return date < maxCacheAge
	}
}
