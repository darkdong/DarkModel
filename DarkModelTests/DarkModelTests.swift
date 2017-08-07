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
    
    func testBasic() {
        class PersonModel: Model {
            var name = ""
            var age = 0
            var birthday: Date?
            var hobbies = [String]()
            var lover: PersonModel?
        }
        
        let girlName = "Yu"
        let girlAge = 16
        let girlBirthday: TimeInterval = 827251200
        let girlHobbies = ["Shopping", "Eating", "Dancing"]
        let girl = PersonModel()
        girl.name = girlName
        girl.age = girlAge
        girl.birthday = Date(timeIntervalSince1970: girlBirthday)
        girl.hobbies = girlHobbies

        let boyName = "Dark"
        let boyAge = 24
        let boyHobbies = ["Metal", "Game"]
        let boy = PersonModel()
        boy.name = boyName
        boy.age = boyAge
        boy.hobbies = boyHobbies
        boy.lover = girl
        
        let keyName = "name"
        let keyAge = "age"
        let keyBirthday = "birthday"
        let keyHobbies = "hobbies"
        let jsonBoy = boy.json()
        
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonBoy))
        XCTAssertEqual(jsonBoy[keyName] as! String, boyName)
        XCTAssertEqual(jsonBoy[keyAge] as! Int, boyAge)
        XCTAssertEqual(jsonBoy[keyHobbies] as! [String], boyHobbies)
        
        let jsonGirl = jsonBoy["lover"] as! [String: Any]
        XCTAssertEqual(jsonGirl[keyName] as! String, girlName)
        XCTAssertEqual(jsonGirl[keyAge] as! Int, girlAge)
        XCTAssertEqual(jsonGirl[keyBirthday] as! TimeInterval, girlBirthday)
        XCTAssertEqual(jsonGirl[keyHobbies] as! [String], girlHobbies)

        let boy2 = PersonModel(json: jsonBoy)
        XCTAssertEqual(boy2.name, boy.name)
        XCTAssertEqual(boy2.age, boy.age)
        XCTAssertNil(boy2.birthday)
        XCTAssertEqual(boy2.hobbies, boy.hobbies)
        
        let girl2 = boy2.lover!
        XCTAssertNotNil(girl2)
        XCTAssertEqual(girl2.name, girl.name)
        XCTAssertEqual(girl2.age, girl.age)
        XCTAssertEqual(girl2.birthday, girl.birthday)
        XCTAssertEqual(girl2.hobbies, girl.hobbies)
    }
    
    func testOptionalInt() {
        class PersonModel: Model {
            var name = ""
            var age: Int?
            
            required init(json: Any?) {
                super.init(json: json)
                
                if let dic = json as? [String: Any] {
                    age = dic[jsonKey("age")] as? Int
                }
            }
            
            override init() {
                super.init()
            }
            
            override func json() -> [String : Any] {
                var dic = super.json()
                if let value = age {
                    dic[jsonKey("age")] = value
                }
                return dic
            }
        }
        
        let boyName = "Dark"
        let boyAge = 24
        let boy = PersonModel()
        boy.name = boyName
        boy.age = boyAge
        
        let jsonBoy = boy.json()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonBoy))
        XCTAssertEqual(jsonBoy["name"] as! String, boyName)
        XCTAssertEqual(jsonBoy["age"] as! Int, boyAge)
        
        let boy2 = PersonModel(json: jsonBoy)
        XCTAssertEqual(boy2.name, boy.name)
        XCTAssertEqual(boy2.age, boy.age)
    }
    
    func testPropertyToJSONKeyMapper() {
        class PersonModel: Model {
            override class var propertyToJSONKeyMapper: [String: String] {
                return ["name": "user_name"]
            }
            var name = ""
            var age = 0
        }
        
        let boyName = "Dark"
        let boyAge = 24
        let boy = PersonModel()
        boy.name = boyName
        boy.age = boyAge
        
        let jsonBoy = boy.json()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonBoy))
        XCTAssertEqual(jsonBoy["user_name"] as! String, boyName)
        XCTAssertEqual(jsonBoy["age"] as! Int, boyAge)

        let boy2 = PersonModel(json: jsonBoy)
        XCTAssertEqual(boy2.name, boy.name)
        XCTAssertEqual(boy2.age, boy.age)
    }

    func testCollectionPropertyToModelTypeMapper() {
        class PersonModel: Model {
            override class var propertyToJSONKeyMapper: [String: String] {
                return ["name": "user_name"]
            }
            override class var propertyToCollectionElementTypeMapper: [String: AnyClass] {
                return ["friends": PersonModel.self, "importantDates": NSDate.self]
            }
            var name = ""
            var age = 0
            var friends = [PersonModel]()
            var importantDates = [Date]()
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

        let boyName = "Dark"
        let boyAge = 24
        let girlBirthday: TimeInterval = 827251200
        let bjOlympicGames: TimeInterval = 1218124800
        let boy = PersonModel()
        boy.name = boyName
        boy.age = boyAge
        boy.friends = [ricky, linda]
        boy.importantDates = [Date(timeIntervalSince1970: girlBirthday), Date(timeIntervalSince1970: bjOlympicGames)]

        let keyName = "user_name"
        let keyAge = "age"
        let jsonBoy = boy.json()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonBoy))
        XCTAssertEqual(jsonBoy[keyName] as! String, boyName)
        XCTAssertEqual(jsonBoy[keyAge] as! Int, boyAge)

        let jsonFriends = jsonBoy["friends"] as! [[String: Any]]
        let jsonRicky = jsonFriends[0]
        XCTAssertEqual(jsonRicky[keyName] as! String, rickyName)
        XCTAssertEqual(jsonRicky[keyAge] as! Int, rickyAge)
        let jsonLinda = jsonFriends[1]
        XCTAssertEqual(jsonLinda[keyName] as! String, lindaName)
        XCTAssertEqual(jsonLinda[keyAge] as! Int, lindaAge)

        let jsonDates = jsonBoy["importantDates"] as! [Double]
        XCTAssertEqual(jsonDates[0], girlBirthday)
        XCTAssertEqual(jsonDates[1], bjOlympicGames)

        let boy2 = PersonModel(json: jsonBoy)
        XCTAssertEqual(boy2.name, boy.name)
        XCTAssertEqual(boy2.age, boy.age)
        XCTAssertEqual(boy2.friends.count, boy.friends.count)
        XCTAssertEqual(boy2.friends[0].name, boy.friends[0].name)
        XCTAssertEqual(boy2.friends[0].age, boy.friends[0].age)
        XCTAssertEqual(boy2.friends[1].name, boy.friends[1].name)
        XCTAssertEqual(boy2.friends[1].age, boy.friends[1].age)
        XCTAssertEqual(boy2.importantDates, boy.importantDates)
    }
}
