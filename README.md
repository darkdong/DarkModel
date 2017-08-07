# DarkModel
A lightweight Swift library that create Model from JSON automatically by introspection.

## Requirements
iOS 8.0, Swift 3.1 

## Installation

### Carthage

1. Add `github "darkdong/DarkModel"` to your Cartfile
2. Run `carthage update --platform ios` and add the framework to your project.
3. import DarkModel

### Manual
Download and add sources to your project

## Usage
All your model classes **MUST** inherit Model

### Basic Usage
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "hobbies": ["Metal", "Game"],
    "homePage": "http://odetodark.com"
    "lover": {
        "name": "Yu",
        "age": 16,
        "birthday": 827251200
        "hobbies": ["Shopping", "Eating", "Dancing"]
    }
}

// Model:
class PersonModel: Model {
    var name = ""
    var age = 0
    var homePage: URL!
    var birthday: Date?
    var hobbies = [String]()
    var lover: PersonModel?
}

let person = PersonModel(json: json)
let json = person.json()

```
### Use Different JSON Key
```
// JSON:
{
    "user_name": "Dark",
    "age": 24,
}

// Model:
class PersonModel: Model {
    override class var propertyToJSONKeyMapper: [String: String] {
        return ["name": "user_name"]
    }
    var name = ""
    var age = 0
}
```
### Property Is Collection *And* Contains Object Which Is Not Auto Convertible 
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "friends": [
        {
            "name": "Ricky",
            "age": 18,
        },
        {
            "name": "Linda",
            "age": 25,
        }
    ],
    "moments": [
        827251200,
        1218124800,
    ]
}

// Model:
class PersonModel: Model {
    override class var propertyToCollectionElementTypeMapper: [String: AnyClass] {
        return ["friends": PersonModel.self, "moments": NSDate.self]
    }
    var name = ""
    var age = 0
    var friends = [PersonModel]()
    var moments = [Date]()
}
```

### Property Is Optinal Int Type
```
// JSON:
{
    "user_name": "Dark",
    "age": 24,
}

// Model:
class PersonModel: Model {
    var name = ""
    var age: Int?

    required init(json: Any?) {
        super.init(json: json)
        
        if let dic = json as? [String: Any] {
            age = dic[jsonKey("age")] as? Int
        }
    }
    
    override func json() -> [String : Any] {
        var dic = super.json()
        if let value = age {
            dic[jsonKey("age")] = value
        }
        return dic
    }
}
```

### Use Custom Conversion
```
    // JSON:
    {
        "birthday": "1996-03-20"
    }

    // Model:
    class PersonModel: Model {
        var birthday: Date!
        
        override func objectFromJSON(_ json: Any?, for property: String) -> Any? {
            switch property {
            case "birthday":
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let string = json as? String {
                    return formatter.date(from: string)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        
        override func jsonFromObject(_ object: Any, for property: String) -> Any? {
            switch property {
            case "birthday":
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: object as! Date)
            default:
                return nil
            }
        }
    }
```
## License

DarkModel is released under the MIT license. [See LICENSE](https://github.com/darkdong/DarkModel/blob/master/LICENSE) for details.

# DarkModel 中文简介
一个轻量级的JSON转模型库, Swift实现。

## 系统需求
iOS 8.0, Swift 3.1 

## 安装

### Carthage
1. 添加 `github "darkdong/DarkModel"` 至 Cartfile
2. 运行 `carthage update --platform ios` 之后添加framework至工程文件中.
3. import DarkModel

### 手动
下载并添加源文件到您的工程文件

## 使用方法
所有类 **必须** 继承自Model

### 零配置用法
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "hobbies": ["Metal", "Game"],
    "homePage": "http://odetodark.com"
    "lover": {
        "name": "Yu",
        "age": 16,
        "birthday": 827251200
        "hobbies": ["Shopping", "Eating", "Dancing"]
    }
}

// Model:
class PersonModel: Model {
    var name = ""
    var age = 0
    var homePage: URL!
    var birthday: Date?
    var hobbies = [String]()
    var lover: PersonModel?
}

let person = PersonModel(json: json)
let json = person.json()
```
### 使用不同的JSON键值
```
// JSON:
{
    "user_name": "Dark",
    "age": 24,
}

// Model:
class PersonModel: Model {
    override class var propertyToJSONKeyMapper: [String: String] {
        return ["name": "user_name"]
    }
    var name = ""
    var age = 0
}
```
### 属性字段是个集合*并且*包含不能自动转换的类型
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "friends": [
        {
            "name": "Ricky",
            "age": 18,
        },
        {
            "name": "Linda",
            "age": 25,
        }
    ],
    "moments": [
        827251200,
        1218124800,
    ]
}

// Model:
class PersonModel: Model {
    override class var propertyToCollectionElementTypeMapper: [String: AnyClass] {
        return ["friends": PersonModel.self, "moments": NSDate.self]
    }
    var name = ""
    var age = 0
    var friends = [PersonModel]()
    var moments = [Date]()
}
```

### 属性类型为 Optinal Int
```
// JSON:
{
    "user_name": "Dark",
    "age": 24,
}

// Model:
class PersonModel: Model {
    var name = ""
    var age: Int?

    required init(json: Any?) {
        super.init(json: json)
        
        if let dic = json as? [String: Any] {
            age = dic[jsonKey("age")] as? Int
        }
    }
    
    override func json() -> [String : Any] {
        var dic = super.json()
        if let value = age {
            dic[jsonKey("age")] = value
        }
        return dic
    }
}
```

### 自定义转换
```
    // JSON:
    {
        "birthday": "1996-03-20"
    }

    // Model:
    class PersonModel: Model {
        var birthday: Date!
        
        override func objectFromJSON(_ json: Any?, for property: String) -> Any? {
            switch property {
            case "birthday":
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let string = json as? String {
                    return formatter.date(from: string)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        
        override func jsonFromObject(_ object: Any, for property: String) -> Any? {
            switch property {
            case "birthday":
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: object as! Date)
            default:
                return nil
            }
        }
    }
```

## 许可证

DarkModel 使用 MIT 许可证。 详见[See LICENSE](https://github.com/darkdong/DarkModel/blob/master/LICENSE)。
