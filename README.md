# DarkModel
A lightweight Swift library that create Model from JSON automaticcaly by introspection.

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

### Simple Usage
```
// JSON:
{
    "name": "Dark",
    "age": 24,
    "hobbies": ["Metal", "Girls"],
    "lover": {
        "name": "Yu",
        "age": 16,
        "hobbies": ["Shopping", "Eating", "Dancing"]
    }
}

// Model:
class PersonModel: Model {
    var name = ""
    var age = 0
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
    override class var propertyKeyMapper: [String: String]? {
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
    var name = ""
    var age = 0
    var friends = [PersonModel]()
}
```

## License

DarkModel is released under the MIT license. [See LICENSE](https://github.com/darkdong/DarkModel/blob/master/LICENSE) for details.