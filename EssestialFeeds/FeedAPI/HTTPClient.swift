//
//  HTTPClient.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 21/03/22.
//

import Foundation
/*
 *** Boundry ***
 */

public typealias HTTPClientResult = Result<(Data,HTTPURLResponse),Error>

public protocol HTTPClient {
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	func get(from url: URL,completion: @escaping(HTTPClientResult) -> Void)
}
