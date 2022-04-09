//
//  SharedTestHelpers.swift
//  EssestialFeedsTests
//
//  Created by YashraJ Gujar on 09/04/22.
//

import Foundation

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
	let url = URL(string: "https://www.a-url.com")!
	return url
}
