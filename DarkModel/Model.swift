//
//  Model.swift
//  DarkModel
//
//  Created by Dark Dong on 2017/6/30.
//  Copyright © 2017年 Dark Dong. All rights reserved.
//

import Foundation

// NOTE: when declares a property of Int type

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

    /// map property key name to JSON key name
    open class var propertyToJSONKeyMapper: [String: String] {
        return [:]
    }

    /// If property is a collection which contains objects of Model type, e.g. [Model], [String: Model]
    /// or foundation type to be coverted, e.g [Date]
    /// property name and its Model type MUST be provided to create collection object correctly:
    open class var propertyToCollectionElementTypeMapper: [String: AnyClass] {
        return [:]
    }
    
    /// convenience to create an array of Model from JSON
    public class func array(from json: Any?) -> [Model] {
        return [Model](json: json, constructor: { (json) -> Model? in
            return self.init(json: json)
        })
    }

    /// convenience to create a dictionary with Model as value from JSON
    public class func dictionary(json: Any?) -> [String: Model] {
        return [String: Model](json: json, constructor: { (json) -> Model? in
            return self.init(json: json)
        })
    }
    
    /// convenience to get property key's according json key
    class func jsonKey(_ propertyKey: String) -> String {
        return propertyToJSONKeyMapper[propertyKey] ?? propertyKey
    }
    
    /// for performance, introspect model property info only once, cache them to reuse
    private static var cachedAllModelPropertyInfos: [String: [PropertyInfo]] = [:]
    
    /// extract property type from attribute string
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
    
    /// extract property read-only attribute
    private static func extractPropertyAttributeReadOnly(from string: String) -> Bool {
        // read-only format: R
        if let char = string.characters.first, char == "R" {
            return true
        }
        
        return false
    }
    
    /// make introspection thread-safe
    private static let semaphore = DispatchSemaphore(value: 1)
    
    /// introspect class to get info of all available properties
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
//            print("--------- properties count", count)
            for i in 0..<Int(count) {
                var info = PropertyInfo()
                let property = properties[i]
                
                let propertyKey = String(cString: property_getName(property)!)
                info.propertyKey = propertyKey
                info.jsonKey = jsonKey(propertyKey)
                
//                print("property:", propertyKey, "attributes:", String(cString: property_getAttributes(property)!))
                
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
                    if propertiesToBeIgnored.contains(propertyKey) {
                        continue
                    }
                    if let classType = info.attributes.classType {
                        // property is of class type
                        if let modelType = classType as? Model.Type {
                            // Model
                            let model = modelType.init(json: jsonValue)
                            setValue(model, forKey: propertyKey)
                        } else if classType is NSDate.Type {
                            // Date
                            if let date = dateFromJSON(jsonValue, for: propertyKey) {
                                setValue(date, forKey: propertyKey)
                            } else {
                                assertionFailure("Can't covert to Date automatically on \"\(propertyKey)\", You must implement your own objectFromJSON(for:) to return Date")
                            }
                        } else if classType is NSURL.Type {
                            // URL
                            if let url = urlFromJSON(jsonValue, for: propertyKey) {
                                setValue(url, forKey: propertyKey)
                            } else {
                                assertionFailure("Can't covert to URL automatically on \"\(propertyKey)\", You must implement your own objectFromJSON(for:) to return URL")
                            }
                        } else if classType is NSArray.Type {
                            // Array
                            if let elementType = type(of: self).propertyToCollectionElementTypeMapper[propertyKey] {
                                if let modelType = elementType as? Model.Type {
                                    let models = modelType.array(from: jsonValue)
                                    setValue(models, forKey: propertyKey)
                                } else if elementType is NSDate.Type {
                                    let objects = [Date](json: jsonValue, constructor: { (json) -> Date? in
                                        return dateFromJSON(json, for: propertyKey)
                                    })
                                    setValue(objects, forKey: propertyKey)
                                } else {
                                    // array which contains only auto-convertible type, e.g. [Int], [String]
                                    setValue(jsonValue, forKey: propertyKey)
                                }
                            } else {
                                // array which contains only auto-convertible type, e.g. [Int], [String]
                                setValue(jsonValue, forKey: propertyKey)
                            }
                        } else if classType is NSDictionary.Type {
                            // Dictionary
                            if let elementType = type(of: self).propertyToCollectionElementTypeMapper[propertyKey] {
                                if let modelType = elementType as? Model.Type {
                                    let models = modelType.dictionary(json: jsonValue)
                                    setValue(models, forKey: propertyKey)
                                } else if elementType is NSDate.Type {
                                    let objects = [String: Date](json: jsonValue, constructor: { (json) -> Date? in
                                        return dateFromJSON(json, for: propertyKey)
                                    })
                                    setValue(objects, forKey: propertyKey)
                                } else {
                                    // dictionary which contains only auto-convertible type, e.g. [String: Int]
                                    setValue(jsonValue, forKey: propertyKey)
                                }
                            } else {
                                // dictionary which contains only auto-convertible type, e.g. [String: Int]
                                setValue(jsonValue, forKey: propertyKey)
                            }
                        } else {
                            // Other class types that can be auto-convertible, e.g. NSNumber, NSString.
                            setValue(jsonValue, forKey: propertyKey)
                        }
                    } else {
                        //property is primitive type
                        setValue(jsonValue, forKey: propertyKey)
                    }
                }
            }
        }
    }
    
    /// display property name and value friendly
    override open var description: String {
        let selfClass = type(of: self)
        var desc = "|\(selfClass)| "
        for info in selfClass.propertyInfos() {
            desc += ", "
            desc += info.propertyKey + ": "
            if let propertyValue = value(forKey: info.propertyKey) {
                desc += "\(propertyValue)"
            } else {
                desc += "nil"
            }
        }
        return desc
    }

    /// convert Model to JSON object
    open func json() -> [String: Any] {
        var dictionary = [String: Any]()
        for info in type(of: self).propertyInfos() {
            if let value = value(forKey: info.propertyKey) {
                let jsonKey = info.jsonKey
                if let model = value as? Model {
                    dictionary[jsonKey] = model.json()
                } else if let date = value as? Date {
                    dictionary[jsonKey] = jsonFromDate(date, for: info.propertyKey)
                } else if let url = value as? URL {
                    dictionary[jsonKey] = jsonFromURL(url, for: info.propertyKey)
                } else if let objects = value as? [Any] {
                    if let models = objects as? [Model] {
                        var array = [Any]()
                        for model in models {
                            array.append(model.json())
                        }
                        dictionary[jsonKey] = array
                    } else if let dates = objects as? [Date] {
                        var array = [Any]()
                        for date in dates {
                            array.append(jsonFromDate(date, for: info.propertyKey))
                        }
                        dictionary[jsonKey] = array
                    } else {
                        dictionary[jsonKey] = objects
                    }
                } else if let objects = value as? [String: Any] {
                    if let models = objects as? [String: Model] {
                        var dic = [String: Any]()
                        for (k, v) in models {
                            dic[k] = v.json()
                        }
                        dictionary[jsonKey] = dic
                    } else if let dates = objects as? [String: Date] {
                        var dic = [String: Any]()
                        for (k, v) in dates {
                            dic[k] = jsonFromDate(v, for: info.propertyKey)
                        }
                        dictionary[jsonKey] = dic
                    }
                }else {
                    dictionary[jsonKey] = value
                }
            }
        }
        return dictionary
    }
    
    open var propertiesToBeIgnored: [String] {
        return []
    }
    
    open func objectFromJSON(_ json: Any?, for property: String) -> Any? {
        return nil
    }
    
    open func jsonFromObject(_ object: Any, for property: String) -> Any? {
        return nil
    }
    
    open func timestampScale(property: String) -> Double {
        return 1
    }
    
    func dateFromJSON(_ json: Any?, for property: String) -> Date? {
        if let date = objectFromJSON(json, for: property) as? Date {
            return date
        } else if let timestamp = json as? TimeInterval {
            let scale = timestampScale(property: property)
            return Date(timeIntervalSince1970: timestamp / scale)
        } else {
            return nil
        }
    }
    
    func urlFromJSON(_ json: Any?, for property: String) -> URL? {
        if let url = objectFromJSON(json, for: property) as? URL {
            return url
        } else if let string = json as? String {
            return URL(string: string)
        } else {
            return nil
        }
    }
    
    func jsonFromDate(_ date: Date, for property: String) -> Any {
        if let json = jsonFromObject(date, for: property) {
            return json
        } else {
            let scale = timestampScale(property: property)
            return date.timeIntervalSince1970 * scale
        }
    }
    
    func jsonFromURL(_ url: URL, for property: String) -> Any {
        if let json = jsonFromObject(url, for: property) {
            return json
        } else {
            return url.absoluteString
        }
    }
    
    /// convert Model to JSON data
    public func jsonData(options: JSONSerialization.WritingOptions = []) -> Data? {
        return try? JSONSerialization.data(withJSONObject: json(), options: options)
    }
    
    /// convert Model to JSON string
    public func jsonString(options: JSONSerialization.WritingOptions = []) -> String? {
        if let data = jsonData(options: options) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    /// convenience to get property key's according json key
    public func jsonKey(_ propertyKey: String) -> String {
        return type(of: self).jsonKey(propertyKey)
    }
}

