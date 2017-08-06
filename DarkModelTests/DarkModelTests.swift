//
//  DarkModelTests.swift
//  DarkModelTests
//
//  Created by Dark Dong on 2017/8/5.
//  Copyright © 2017年 Dark Dong. All rights reserved.
//

import XCTest
import DarkModel

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
    
    func testSimple() {
        class PersonModel: Model {
            var name = ""
            var age = 0
            var hobbies = [String]()
            var lover: PersonModel?
        }
        
        let loverName = "Yu"
        let loverAge = 16
        let loverHobbies = ["Shopping", "Eating", "Dancing"]
        var lover = PersonModel()
        lover.name = loverName
        lover.age = loverAge
        lover.hobbies = loverHobbies

        let darkName = "Dark"
        let darkAge = 24
        let darkHobbies = ["Metal", "Girls"]
        var dark = PersonModel()
        dark.name = darkName
        dark.age = darkAge
        dark.hobbies = darkHobbies
        dark.lover = lover
        
        let keyName = "name"
        let keyAge = "age"
        let keyHobbies = "hobbies"
        let json = dark.json()
        
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json))
        XCTAssertEqual(json[keyName] as! String, darkName)
        XCTAssertEqual(json[keyAge] as! Int, darkAge)
        XCTAssertEqual(json[keyHobbies] as! [String], darkHobbies)
        
        let jsonLover = json["lover"] as! [String: Any]
        XCTAssertEqual(jsonLover[keyName] as! String, loverName)
        XCTAssertEqual(jsonLover[keyAge] as! Int, loverAge)
        XCTAssertEqual(jsonLover[keyHobbies] as! [String], loverHobbies)

        dark = PersonModel(json: json)
        XCTAssertEqual(dark.name, darkName)
        XCTAssertEqual(dark.age, darkAge)
        XCTAssertEqual(dark.hobbies, darkHobbies)
        
        lover = dark.lover!
        XCTAssertNotNil(lover)
        XCTAssertEqual(lover.name, loverName)
        XCTAssertEqual(lover.age, loverAge)
        XCTAssertEqual(lover.hobbies, loverHobbies)
    }
    
    func testPropertyKeyMapper() {
        class PersonModel: Model {
            override class var propertyKeyMapper: [String: String] {
                return ["name": "user_name"]
            }
            var name = ""
            var age = 0
        }
        
        let darkName = "Dark"
        let darkAge = 24
        
        var dark = PersonModel()
        dark.name = darkName
        dark.age = darkAge
        
        let json = dark.json()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json))
        XCTAssertEqual(json["user_name"] as! String, darkName)
        XCTAssertEqual(json["age"] as! Int, darkAge)

        dark = PersonModel(json: json)
        XCTAssertEqual(dark.name, darkName)
        XCTAssertEqual(dark.age, darkAge)
    }
    
    func testModelCollectionProperty() {
        class PersonModel: Model {
            override class var propertyKeyMapper: [String: String] {
                return ["name": "user_name"]
            }
            override class var modelCollectionProperties: [String: Model.Type] {
                return ["friends": PersonModel.self]
            }
            var name = ""
            var age = 0
            var friends = [PersonModel]()
        }
        
        let rickyName = "Ricky"
        let rickyAge = 18
        let ricky = PersonModel()
        ricky.name = rickyName
        ricky.age = rickyAge

        let lindaName = "Linda"
        let lindaAge = 25
        let linda = PersonModel()
        linda.name = lindaName
        linda.age = lindaAge

        let darkName = "Dark"
        let darkAge = 24
        var dark = PersonModel()
        dark.name = darkName
        dark.age = darkAge
        dark.friends = [ricky, linda]
        
        let keyName = "user_name"
        let keyAge = "age"
        let json = dark.json()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json))
        XCTAssertEqual(json[keyName] as! String, darkName)
        XCTAssertEqual(json[keyAge] as! Int, darkAge)

        let jsonFriends = json["friends"] as! [[String: Any]]
        let jsonRicky = jsonFriends[0]
        XCTAssertEqual(jsonRicky[keyName] as! String, rickyName)
        XCTAssertEqual(jsonRicky[keyAge] as! Int, rickyAge)
        let jsonLinda = jsonFriends[1]
        XCTAssertEqual(jsonLinda[keyName] as! String, lindaName)
        XCTAssertEqual(jsonLinda[keyAge] as! Int, lindaAge)

        dark = PersonModel(json: json)
        XCTAssertEqual(dark.name, darkName)
        XCTAssertEqual(dark.age, darkAge)
        XCTAssertEqual(dark.friends.count, 2)
        XCTAssertEqual(dark.friends[0].name, rickyName)
        XCTAssertEqual(dark.friends[0].age, rickyAge)
        XCTAssertEqual(dark.friends[1].name, lindaName)
        XCTAssertEqual(dark.friends[1].age, lindaAge)
    }
}
