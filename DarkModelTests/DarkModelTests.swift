//
//  DarkModelTests.swift
//  DarkModelTests
//
//  Created by Dark Dong on 2017/8/5.
//  Copyright © 2017年 Dark Dong. All rights reserved.
//

import XCTest
import DarkModel

class PersonModel: Model {
    var name = ""
    var age = 0
    var hobbies = [String]()
    var lover: PersonModel?
}

class DarkModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSimpleJSON() {
        let string = "{\"name\": \"Dark\", \"age\": 24, \"hobbies\": [\"Metal\", \"Girls\"], \"lover\": {\"name\": \"Yu\", \"age\": 16, \"hobbies\": [\"Shopping\", \"Eating\", \"Dancing\"]}}"
        let data = string.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data)
        
        let person = PersonModel(json: json)
        
        XCTAssert(person.name == "Dark")
        XCTAssert(person.age == 24)
        XCTAssert(person.hobbies == ["Metal", "Girls"])
        let lover: PersonModel! = person.lover
        XCTAssert(lover != nil)
        XCTAssert(lover.name == "Yu")
        XCTAssert(lover.age == 16)
        XCTAssert(lover.hobbies == ["Shopping", "Eating", "Dancing"])
    }
}
