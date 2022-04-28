//
//  EssestialFeedsCacheIntegrationTests.swift
//  EssestialFeedsCacheIntegrationTests
//
//  Created by YashraJ Gujar on 28/04/22.
//

import XCTest
import EssestialFeeds

///Idea is to integrate all the cache model objects and see how they behave in collaboration with real instances of production types.
class EssestialFeedsCacheIntegrationTests: XCTestCase {
	
	func test_load_deliversNoItemsOnEmptyCache(){
		let sut = makeSUT()
		
		let expect = expectation(description: "wait for load completion")
		
		sut.load { result in
			switch result {
				case let .success(imageFeed):
					XCTAssertEqual(imageFeed, [], "Expected empty feed")
				case let .failure(error):
					XCTFail("Expetcted successful feed result, got \(error) instead")
			}
			expect.fulfill()
		}
		
		wait(for: [expect], timeout: 1.0)
	}
	
	
	//MARK:- HELPERS
	func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = testSpecificStoreURL()
		let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		let sut = LocalFeedLoader(store: store, currentDate: Date.init)
		trackForMemoryLeaks(store,file:file, line:line)
		trackForMemoryLeaks(sut,file: file, line: line)
		return sut
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
