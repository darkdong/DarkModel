//
//  Extension.swift
//  DarkModel
//
//  Created by Dark Dong on 2017/8/5.
//  Copyright © 2017年 Dark Dong. All rights reserved.
//

import Foundation

public extension Array {
    init(json: Any?, constructor: (Any?) -> Element?) {
        self.init()
        
        if let jsonArray = json as? [Any?] {
            reserveCapacity(jsonArray.count)
            for any in jsonArray {
                if let element = constructor(any) {
                    append(element)
                }
            }
        }
    }
}

public extension Dictionary {
    init(json: Any?, constructor: (Any?) -> Value?) {
        self.init()
        
        if let jsonDic = json as? [Key: Any] {
            for (key, value) in jsonDic {
                if let model = constructor(value) {
                    self[key] = model
                }
            }
        }
    }
}
