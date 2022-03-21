//
//  HTTPClient.swift
//  EssestialFeeds
//
//  Created by YashraJ Gujar on 21/03/22.
//

import Foundation

public enum HTTPClientResult {
	case success(Data,HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	
	func getFrom(from url: URL,completion: @escaping(HTTPClientResult) -> Void)
}
