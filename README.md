# DarkModel
A lightweight Swift library that create Model from JSON automatically by introspection.

## Requirements
iOS 8.0, Swift 3.1 

## Installation

### Carthage
```
github "darkdong/DarkModel"
```

### Manual
Download and add sources to your project

## Usage
If you use framework
```
import DarkModel
```
All your model classes **MUST** inherit Model

### Basic Usage
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "hobbies": ["Metal", "Game"],
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
    var birthday: Date?
    var hobbies = [String]()
    var lover: PersonModel?
}

let person = PersonModel(json: json)
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
### Property Is Collection Type *And* Contains Model
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
    ]
}

// Model:
class PersonModel: Model {
    override class var collectionPropertyToModelTypeMapper: [String: Model.Type] {
        return ["friends": PersonModel.self]
    }
    var name = ""
    var age = 0
    var friends = [PersonModel]()
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
```
github "darkdong/DarkModel"
```

### 手动
下载并添加源文件到您的工程文件

## 使用方法
如果使用 framework 的话
```
import DarkModel
```
所有类 **必须** 继承自Model

### 零配置用法
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "hobbies": ["Metal", "Game"],
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
    var birthday: Date?
    var hobbies = [String]()
    var lover: PersonModel?
}

let person = PersonModel(json: json)
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
### 属性字段是集合类型*并且*包含Model类型
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
    ]
}

// Model:
class PersonModel: Model {
    override class var collectionPropertyToModelTypeMapper: [String: Model.Type] {
        return ["friends": PersonModel.self]
    }
    var name = ""
    var age = 0
    var friends = [PersonModel]()
}
```

## 许可证

DarkModel 使用 MIT 许可证。 详见[See LICENSE](https://github.com/darkdong/DarkModel/blob/master/LICENSE)。
