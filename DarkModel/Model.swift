//
//  Model.swift
//  DarkModel
//
//  Created by Dark Dong on 2017/6/30.
//  Copyright © 2017年 Dark Dong. All rights reserved.
//

import Foundation

// NOTE: all custom model must inherits Model.
// when declare a property in Model, the type of property:
// must NOT be optional if it is Swift struct type or primitive type;
// can be optional if it is Objective-C class.

// var anInt: Int = 0 // correct
// var anInt: NSInteger = 0 // correct
// var anInt: NSNumber? // correct
// var anInt: NSNumber! // correct

// var anOptionalInt: Int? // incorrect
// var anOptionalInt: Int! // incorrect
// var anOptionalInt: NSInteger? // incorrect
// var anOptionalInt: NSInteger! // incorrect

// if you really wannna declare an instance of optional struct type such as Int?, 
// you must initiate it by yourself（override Model.init(json:) and write your own parsing statements）

open class Model: NSObject {
    struct PropertyAttributes {
        static let keyType = "T"
        static let keyReadOnly = "R"
        
        var classType: AnyClass?
        var isReadOnly = false
    }
    
    struct PropertyInfo {
        var propertyKey = ""
        var jsonKey = ""
        var attributes = PropertyAttributes()
    }
    
    open class var propertyKeyMapper: [String: String]? {
        return nil
    }

    //If collection property which contain objects of Model Type, such as [Model], [String: Model]
    //property name and its class type MUST be provided:
    open class var modelCollectionProperties: [String: Model.Type] {
        return [:]
    }
    
    //convenience to create an array of Model from JSON
    public class func array(json: Any?) -> [Model] {
        return [Model](json: json, constructor: { (json) -> Model? in
            return self.init(json: json)
        })
    }

    //convenience to create a dictionary with Model as value from JSON
    public class func dictionary(json: Any?) -> [String: Model] {
        return [String: Model](json: json, constructor: { (json) -> Model? in
            return self.init(json: json)
        })
    }
    
    //convenience to get property key's according json key
    class func jsonKey(_ propertyKey: String) -> String {
        return propertyKeyMapper?[propertyKey] ?? propertyKey
    }
    
    //for performance, introspect model property info only once, cache them to reuse
    private static var cachedAllModelPropertyInfos: [String: [PropertyInfo]] = [:]
    
    //extract property type from attribute string
    private static func extractPropertyAttributeType(from string: String) -> AnyClass? {
        // type string format: @"ClassName", B, q, f
        if let char = string.characters.first, char == "@" {
            //type is NSObject
            let start = string.index(string.startIndex, offsetBy: 2) //skip first two chars: @"
            let end = string.index(string.endIndex, offsetBy: -1) // until the last char "
            let className = string.substring(with: start..<end)
            return NSClassFromString(className)
        }
        
        return nil
    }
    
    //extract property read-only attribute
    private static func extractPropertyAttributeReadOnly(from string: String) -> Bool {
        // read-only format: R
        if let char = string.characters.first, char == "R" {
            return true
        }
        
        return false
    }
    
    //for introspection thread-safe
    private static let semaphore = DispatchSemaphore(value: 1)
    
    //introspect class to get info of all available properties
    class func propertyInfos() -> [PropertyInfo] {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        let key = NSStringFromClass(self)
        if let infos = cachedAllModelPropertyInfos[key] {
            return infos
        }
        
        //create all properties through class introspection and cache all property info
        var infos: [PropertyInfo] = []
        var count: UInt32 = 0
        if let properties = class_copyPropertyList(self, &count) {
            print("--------- properties count", count)
            for i in 0..<Int(count) {
                var info = PropertyInfo()
                let property = properties[i]
                
                let propertyKey = String(cString: property_getName(property)!)
                info.propertyKey = propertyKey
                info.jsonKey = jsonKey(propertyKey)
                
                print("property:", propertyKey, "attributes:", String(cString: property_getAttributes(property)!))
                
                if let cstring = property_copyAttributeValue(property, PropertyAttributes.keyType) {
                    let string = String(cString: cstring)
                    info.attributes.classType = extractPropertyAttributeType(from: string)
                    free(cstring)
                }
                
                if let cstring = property_copyAttributeValue(property, PropertyAttributes.keyReadOnly) {
                    let string = String(cString: cstring)
                    info.attributes.isReadOnly = extractPropertyAttributeReadOnly(from: string)
                    free(cstring)
                }
                
                if !info.attributes.isReadOnly {
                    infos.append(info)
                }
            }
            free(properties)
        }

        cachedAllModelPropertyInfos[key] = infos
        return infos
    }
    
    override public init() {
        super.init()
    }
    
    required public init(json: Any?) {
        super.init()
        
        if let dic = json as? [String: Any] {
            for info in type(of: self).propertyInfos() {
                if let jsonValue = dic[info.jsonKey] {
                    let propertyKey = info.propertyKey
                    if let classType = info.attributes.classType {
                        if let modelType = classType as? Model.Type {
                            //property is of Model type, create it as Model and set it
                            let model = modelType.init(json: jsonValue)
                            setValue(model, forKey: propertyKey)
                        }
                        else {
                            //property is of non-Model type such as NSArray, NSDictionary, NSDate, NSData...
                            if let modelType = type(of: self).modelCollectionProperties[propertyKey] {
                                //for collections which contain objects of Model Type, such as [Model], [String: Model]
                                //additional info must be provided: property name and its class type
                                if classType is NSArray.Type {
                                    let models = modelType.array(json: jsonValue)
                                    setValue(models, forKey: propertyKey)
                                } else if classType is NSDictionary.Type {
                                    let models = modelType.dictionary(json: jsonValue)
                                    setValue(models, forKey: propertyKey)
                                }
                            } else {
                                // just set value directly
                                //1. for non-collection class, such as: NSDate, NSData
                                //2. and collection class which only contain foundation objects, such as: [Int], [String: NSDate]
                                setValue(jsonValue, forKey: propertyKey)
                            }
                        }
                    } else {
                        //property is primitive type, set it directly
                        setValue(jsonValue, forKey: propertyKey)
                    }
                }
            }
        }
    }
    
    //display property name and value friendly
    override open var description: String {
        let selfClass = type(of: self)
        var desc = "|\(selfClass)| "
        for info in selfClass.propertyInfos() {
            desc += info.propertyKey + ": "
            if let propertyValue = value(forKey: info.propertyKey) {
                desc += "\(propertyValue)"
            }
            desc += ", "
        }
        return desc
    }

    //convert Model to JSON object
    open func json() -> [String: Any] {
        var dictionary = [String: Any]()
        for info in type(of: self).propertyInfos() {
            if let value = value(forKey: info.propertyKey) {
                let jsonKey = info.jsonKey
                if let model = value as? Model {
                    dictionary[jsonKey] = model.json()
                } else if let models = value as? [Model] {
                    var array = [Any]()
                    for model in models {
                        array.append(model.json())
                    }
                    dictionary[jsonKey] = array
                } else if let models = value as? [String: Model] {
                    var dic = [String: Any]()
                    for (k, v) in models {
                        dic[k] = v
                    }
                    dictionary[jsonKey] = dic
                } else {
                    dictionary[jsonKey] = value
                }
            }
        }
        return dictionary
    }
    
    //convert Model to JSON data
    public func jsonData(options: JSONSerialization.WritingOptions = []) -> Data? {
        return try? JSONSerialization.data(withJSONObject: json(), options: options)
    }
    
    //convert Model to JSON string
    public func jsonString(options: JSONSerialization.WritingOptions = []) -> String? {
        if let data = jsonData(options: options) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    //convenience to get property key's according json key
    public func jsonKey(_ propertyKey: String) -> String {
        return type(of: self).jsonKey(propertyKey)
    }
}

