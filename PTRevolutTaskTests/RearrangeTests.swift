//
//  RearrangeTests.swift
//  PTRevolutTaskTests
//
//  Created by Petko Todorov on 10/7/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import XCTest
@testable import PTRevolutTask

class RearrangeTests: XCTestCase {
    
    var arr: [Int]!
    
    override func setUp() {
        super.setUp()
        arr = [1,2,3,4,5]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFirstToLast() {
        arr.rearrange(from: 0, to: arr.count-1)
        XCTAssert(arr[0] == 2)
        XCTAssert(arr[arr.count-1] == 1)
    }
    
    func testLastToFirst() {
        arr.rearrange(from: arr.count-1, to: 0)
        XCTAssert(arr[0] == 5)
        XCTAssert(arr[arr.count-1] == 4)
    }
    
    func testMiddleToFirst() {
        arr.rearrange(from: 2, to: 0)
        XCTAssert(arr[0] == 3)
        XCTAssert(arr[2] == 2)
        XCTAssert(arr[arr.count-1] == 5)
    }
    
    func testMiddleToLast() {
        arr.rearrange(from: 2, to: arr.count-1)
        XCTAssert(arr[0] == 1)
        XCTAssert(arr[2] == 4)
        XCTAssert(arr[arr.count-1] == 3)
    }
    
    func testFirstToOutOfBounds() {
        arr.rearrange(from: 0, to: arr.count)
        XCTAssert(arr[0] == 1)
        XCTAssert(arr[4] == 5)
    }
    
    func testLastToOutOfBounds() {
        arr.rearrange(from: arr.count-1, to: -1)
        XCTAssert(arr[0] == 1)
        XCTAssert(arr[4] == 5)
    }
    
    
}
