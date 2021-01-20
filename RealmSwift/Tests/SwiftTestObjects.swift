////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import RealmSwift
import Realm

class SwiftStringObject: Object {
    @ManagedProperty var stringCol = ""
}

class SwiftBoolObject: Object {
    @ManagedProperty var boolCol = false
}

class SwiftIntObject: Object {
    @ManagedProperty var intCol = 0
}

class SwiftInt8Object: Object {
    @ManagedProperty var int8Col = 0
}

class SwiftInt16Object: Object {
    @ManagedProperty var int16Col = 0
}

class SwiftInt32Object: Object {
    @ManagedProperty var int32Col = 0
}

class SwiftInt64Object: Object {
    @ManagedProperty var int64Col = 0
}

class SwiftLongObject: Object {
    @ManagedProperty var longCol: Int64 = 0
}

@objc enum IntEnum: Int, RealmEnum, _ManagedPropertyType {
    case value1 = 1
    case value2 = 3
}

class SwiftObject: Object {
    @ManagedProperty var boolCol = false
    @ManagedProperty var intCol = 123
    @ManagedProperty var int8Col: Int8 = 123
    @ManagedProperty var int16Col: Int16 = 123
    @ManagedProperty var int32Col: Int32 = 123
    @ManagedProperty var int64Col: Int64 = 123
    @ManagedProperty var intEnumCol = IntEnum.value1
    @ManagedProperty var floatCol = 1.23 as Float
    @ManagedProperty var doubleCol = 12.3
    @ManagedProperty var stringCol = "a"
    @ManagedProperty var binaryCol = "a".data(using: String.Encoding.utf8)!
    @ManagedProperty var dateCol = Date(timeIntervalSince1970: 1)
    @ManagedProperty var decimalCol = Decimal128("123e4")
    @ManagedProperty var objectIdCol = ObjectId("1234567890ab1234567890ab")
    @ManagedProperty var objectCol: SwiftBoolObject? = SwiftBoolObject()
    @ManagedProperty var arrayCol: List<SwiftBoolObject>

    class func defaultValues() -> [String: Any] {
        return  [
            "boolCol": false,
            "intCol": 123,
            "int8Col": 123 as Int8,
            "int16Col": 123 as Int16,
            "int32Col": 123 as Int32,
            "int64Col": 123 as Int64,
            "floatCol": 1.23 as Float,
            "doubleCol": 12.3,
            "stringCol": "a",
            "binaryCol": "a".data(using: String.Encoding.utf8)!,
            "dateCol": Date(timeIntervalSince1970: 1),
            "decimalCol": Decimal128("123e4"),
            "objectIdCol": ObjectId("1234567890ab1234567890ab"),
            "objectCol": [false],
            "arrayCol": []
        ]
    }
}

class SwiftOptionalObject: Object {
    @objc dynamic var optNSStringCol: NSString?
    @ManagedProperty var optStringCol: String?
    @ManagedProperty var optBinaryCol: Data?
    @ManagedProperty var optDateCol: Date?
    @ManagedProperty var optDecimalCol: Decimal128?
    @ManagedProperty var optObjectIdCol: ObjectId?
    @ManagedProperty var optIntCol: Int? = nil
    @ManagedProperty var optFloatCol: Float? = nil
    @ManagedProperty var optDoubleCol: Double? = nil
    @ManagedProperty var optBoolCol: Bool? = nil
    @ManagedProperty var optInt8Col: Int8?
    @ManagedProperty var optInt16Col: Int16?
    @ManagedProperty var optInt32Col: Int32?
    @ManagedProperty var optInt64Col: Int64?
    @ManagedProperty var optEnumCol: IntEnum?
    @ManagedProperty var optObjectCol: SwiftBoolObject?
}

class SwiftRealmOptionalObject: Object {
    let optIntCol = RealmOptional<Int>()
    let optFloatCol = RealmOptional<Float>()
    let optDoubleCol = RealmOptional<Double>()
    let optBoolCol = RealmOptional<Bool>()
    let optInt8Col = RealmOptional<Int8>()
    let optInt16Col = RealmOptional<Int16>()
    let optInt32Col = RealmOptional<Int32>()
    let optInt64Col = RealmOptional<Int64>()
    let optEnumCol = RealmOptional<IntEnum>()
}

class SwiftOptionalPrimaryObject: SwiftOptionalObject {
    @ManagedProperty(primaryKey: true) var id: Int?
}

class ManagedPropertyWrapper: Object {
    @ManagedProperty(wrappedValue: 0, primaryKey: true)
    var value: Int
}

class SwiftListObject: Object {
    @ManagedProperty var int: List<Int>
    @ManagedProperty var int8: List<Int8>
    @ManagedProperty var int16: List<Int16>
    @ManagedProperty var int32: List<Int32>
    @ManagedProperty var int64: List<Int64>
    @ManagedProperty var float: List<Float>
    @ManagedProperty var double: List<Double>
    @ManagedProperty var string: List<String>
    @ManagedProperty var data: List<Data>
    @ManagedProperty var date: List<Date>
    @ManagedProperty var decimal: List<Decimal128>
    @ManagedProperty var objectId: List<ObjectId>

    @ManagedProperty var intOpt: List<Int?>
    @ManagedProperty var int8Opt: List<Int8?>
    @ManagedProperty var int16Opt: List<Int16?>
    @ManagedProperty var int32Opt: List<Int32?>
    @ManagedProperty var int64Opt: List<Int64?>
    @ManagedProperty var floatOpt: List<Float?>
    @ManagedProperty var doubleOpt: List<Double?>
    @ManagedProperty var stringOpt: List<String?>
    @ManagedProperty var dataOpt: List<Data?>
    @ManagedProperty var dateOpt: List<Date?>
    @ManagedProperty var decimalOpt: List<Decimal128?>
    @ManagedProperty var objectIdOpt: List<ObjectId?>
}

class SwiftImplicitlyUnwrappedOptionalObject: Object {
    @objc dynamic var optNSStringCol: NSString!
    @ManagedProperty var optStringCol: String!
    @ManagedProperty var optBinaryCol: Data!
    @ManagedProperty var optDateCol: Date!
    @ManagedProperty var optDecimalCol: Decimal128!
    @ManagedProperty var optObjectIdCol: ObjectId!
    @ManagedProperty var optObjectCol: SwiftBoolObject!
}

class SwiftOptionalDefaultValuesObject: Object {
    @objc dynamic var optNSStringCol: NSString? = "A"
    @ManagedProperty var optStringCol: String? = "B"
    @ManagedProperty var optBinaryCol: Data? = "C".data(using: String.Encoding.utf8)! as Data
    @ManagedProperty var optDateCol: Date? = Date(timeIntervalSince1970: 10)
    @ManagedProperty var optDecimalCol: Decimal128? = "123"
    @ManagedProperty var optObjectIdCol: ObjectId? = ObjectId("1234567890ab1234567890ab")
    @ManagedProperty var optIntCol: Int? = 1
    @ManagedProperty var optInt8Col: Int8? = 1
    @ManagedProperty var optInt16Col: Int16? = 1
    @ManagedProperty var optInt32Col: Int32? = 1
    @ManagedProperty var optInt64Col: Int64? = 1
    @ManagedProperty var optFloatCol: Float? = 2.2
    @ManagedProperty var optDoubleCol: Double? = 3.3
    @ManagedProperty var optBoolCol: Bool? = true
    @ManagedProperty var optObjectCol: SwiftBoolObject? = SwiftBoolObject(value: [true])
    //    @ManagedProperty var arrayCol: List<SwiftBoolObject?>

    class func defaultValues() -> [String: Any] {
        return [
            "optNSStringCol": "A",
            "optStringCol": "B",
            "optBinaryCol": "C".data(using: String.Encoding.utf8)!,
            "optDateCol": Date(timeIntervalSince1970: 10),
            "optDecimalCol": Decimal128("123"),
            "optObjectIdCol": ObjectId("1234567890ab1234567890ab"),
            "optIntCol": 1,
            "optInt8Col": Int8(1),
            "optInt16Col": Int16(1),
            "optInt32Col": Int32(1),
            "optInt64Col": Int64(1),
            "optFloatCol": 2.2 as Float,
            "optDoubleCol": 3.3,
            "optBoolCol": true
        ]
    }
}

class SwiftOptionalIgnoredPropertiesObject: Object {
    @objc dynamic var id = 0

    @objc dynamic var optNSStringCol: NSString? = "A"
    @objc dynamic var optStringCol: String? = "B"
    @objc dynamic var optBinaryCol: Data? = "C".data(using: String.Encoding.utf8)! as Data
    @objc dynamic var optDateCol: Date? = Date(timeIntervalSince1970: 10)
    @objc dynamic var optDecimalCol: Decimal128? = "123"
    @objc dynamic var optObjectIdCol: ObjectId? = ObjectId("1234567890ab1234567890ab")
    @objc dynamic var optObjectCol: SwiftBoolObject? = SwiftBoolObject(value: [true])

    override class func ignoredProperties() -> [String] {
        return [
            "optNSStringCol",
            "optStringCol",
            "optBinaryCol",
            "optDateCol",
            "optDecimalCol",
            "optObjectIdCol",
            "optObjectCol"
        ]
    }
}

class SwiftDogObject: Object {
    @ManagedProperty var dogName = ""
    @ManagedProperty(originProperty: "dog")
    var owners: LinkingObjects<SwiftOwnerObject>
}

class SwiftOwnerObject: Object {
    @ManagedProperty var name = ""
    @ManagedProperty var dog: SwiftDogObject? = SwiftDogObject()
}

class SwiftAggregateObject: Object {
    @ManagedProperty var intCol = 0
    @ManagedProperty var int8Col: Int8 = 0
    @ManagedProperty var int16Col: Int16 = 0
    @ManagedProperty var int32Col: Int32 = 0
    @ManagedProperty var int64Col: Int64 = 0
    @ManagedProperty var floatCol = 0 as Float
    @ManagedProperty var doubleCol = 0.0
    @ManagedProperty var decimalCol = 0.0 as Decimal128
    @ManagedProperty var boolCol = false
    @ManagedProperty var dateCol = Date()
    @ManagedProperty var trueCol = true
    @ManagedProperty var stringListCol: List<SwiftStringObject>
}

class SwiftAllIntSizesObject: Object {
    @ManagedProperty var int8: Int8  = 0
    @ManagedProperty var int16: Int16 = 0
    @ManagedProperty var int32: Int32 = 0
    @ManagedProperty var int64: Int64 = 0
}

class SwiftEmployeeObject: Object {
    @ManagedProperty var name = ""
    @ManagedProperty var age = 0
    @ManagedProperty var hired = false
}

class SwiftCompanyObject: Object {
    @ManagedProperty var employees: List<SwiftEmployeeObject>
}

class SwiftArrayPropertyObject: Object {
    @ManagedProperty var name = ""
    @ManagedProperty var array: List<SwiftStringObject>
    @ManagedProperty var intArray: List<SwiftIntObject>
}

class SwiftDoubleListOfSwiftObject: Object {
    @ManagedProperty var array: List<SwiftListOfSwiftObject>
}

class SwiftListOfSwiftObject: Object {
    @ManagedProperty var array: List<SwiftObject>
}

class SwiftListOfSwiftOptionalObject: Object {
    @ManagedProperty var array: List<SwiftOptionalObject>
}

class SwiftArrayPropertySubclassObject: SwiftArrayPropertyObject {
    @ManagedProperty var boolArray: List<SwiftBoolObject>
}

class SwiftLinkToPrimaryStringObject: Object {
    @ManagedProperty(primaryKey: true) var pk = ""
    @ManagedProperty var object: SwiftPrimaryStringObject?
    @ManagedProperty var objects: List<SwiftPrimaryStringObject>
}

class SwiftUTF8Object: Object {
    // swiftlint:disable:next identifier_name
    @ManagedProperty var 柱колоéнǢкƱаم👍 = "值значен™👍☞⎠‱௹♣︎☐▼❒∑⨌⧭иеمرحبا"
}

class SwiftIgnoredPropertiesObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    @objc dynamic var runtimeProperty: AnyObject?
    @objc dynamic var runtimeDefaultProperty = "property"
    @objc dynamic var readOnlyProperty: Int { return 0 }

    override class func ignoredProperties() -> [String] {
        return ["runtimeProperty", "runtimeDefaultProperty"]
    }
}

class SwiftRecursiveObject: Object {
    @ManagedProperty var objects: List<SwiftRecursiveObject>
}

protocol SwiftPrimaryKeyObjectType {
    associatedtype PrimaryKey
}

class SwiftPrimaryStringObject: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty(primaryKey: true) var stringCol = ""
    @ManagedProperty var intCol = 0

    typealias PrimaryKey = String
}

class SwiftPrimaryOptionalStringObject: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty(primaryKey: true) var stringCol: String? = ""
    @ManagedProperty var intCol = 0

    typealias PrimaryKey = String?
}

class SwiftPrimaryIntObject: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var intCol = 0

    typealias PrimaryKey = Int
}

class SwiftPrimaryOptionalIntObject: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var intCol: Int?

    typealias PrimaryKey = RealmOptional<Int>
}

class SwiftPrimaryInt8Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int8Col: Int8 = 0

    typealias PrimaryKey = Int8
}

class SwiftPrimaryOptionalInt8Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int8Col: Int8?

    typealias PrimaryKey = RealmOptional<Int8>
}

class SwiftPrimaryInt16Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int16Col: Int16 = 0

    typealias PrimaryKey = Int16
}

class SwiftPrimaryOptionalInt16Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int16Col: Int16?

    typealias PrimaryKey = RealmOptional<Int16>
}

class SwiftPrimaryInt32Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int32Col: Int32 = 0

    typealias PrimaryKey = Int32
}

class SwiftPrimaryOptionalInt32Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int32Col: Int32?

    typealias PrimaryKey = RealmOptional<Int32>
}

class SwiftPrimaryInt64Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int64Col: Int64 = 0

    typealias PrimaryKey = Int64
}

class SwiftPrimaryOptionalInt64Object: Object, SwiftPrimaryKeyObjectType {
    @ManagedProperty var stringCol = ""
    @ManagedProperty(primaryKey: true) var int64Col: Int64?

    typealias PrimaryKey = RealmOptional<Int64>
}

class SwiftIndexedPropertiesObject: Object {
    @ManagedProperty(indexed: true) var stringCol = ""
    @ManagedProperty(indexed: true) var intCol = 0
    @ManagedProperty(indexed: true) var int8Col: Int8 = 0
    @ManagedProperty(indexed: true) var int16Col: Int16 = 0
    @ManagedProperty(indexed: true) var int32Col: Int32 = 0
    @ManagedProperty(indexed: true) var int64Col: Int64 = 0
    @ManagedProperty(indexed: true) var boolCol = false
    @ManagedProperty(indexed: true) var dateCol = Date()

    @ManagedProperty var floatCol: Float = 0.0
    @ManagedProperty var doubleCol: Double = 0.0
    @ManagedProperty var dataCol = Data()
}

class SwiftIndexedOptionalPropertiesObject: Object {
    @ManagedProperty(indexed: true) var optionalStringCol: String? = ""
    @ManagedProperty(indexed: true) var optionalIntCol: Int?
    @ManagedProperty(indexed: true) var optionalInt8Col: Int8?
    @ManagedProperty(indexed: true) var optionalInt16Col: Int16?
    @ManagedProperty(indexed: true) var optionalInt32Col: Int32?
    @ManagedProperty(indexed: true) var optionalInt64Col: Int64?
    @ManagedProperty(indexed: true) var optionalBoolCol: Bool?
    @ManagedProperty(indexed: true) var optionalDateCol: Date? = Date()

    @ManagedProperty var optionalFloatCol: Float?
    @ManagedProperty var optionalDoubleCol: Double?
    @ManagedProperty var optionalDataCol: Data? = Data()
}

class SwiftCustomInitializerObject: Object {
    @ManagedProperty var stringCol: String

    init(stringVal: String) {
        stringCol = stringVal
        super.init()
    }

    required override init() {
        stringCol = ""
        super.init()
    }
}

class SwiftConvenienceInitializerObject: Object {
    @ManagedProperty var stringCol = ""

    convenience init(stringCol: String) {
        self.init()
        self.stringCol = stringCol
    }
}

class SwiftObjectiveCTypesObject: Object {
    @objc dynamic var stringCol: NSString?
    @objc dynamic var dateCol: NSDate?
    @objc dynamic var dataCol: NSData?
}

class SwiftComputedPropertyNotIgnoredObject: Object {
    // swiftlint:disable:next identifier_name
    @ManagedProperty var _urlBacking = ""

    // Dynamic; no ivar
    @objc dynamic var dynamicURL: URL? {
        get {
            return URL(string: _urlBacking)
        }
        set {
            _urlBacking = newValue?.absoluteString ?? ""
        }
    }

    // Non-dynamic; no ivar
    var url: URL? {
        get {
            return URL(string: _urlBacking)
        }
        set {
            _urlBacking = newValue?.absoluteString ?? ""
        }
    }
}

@objc(SwiftObjcRenamedObject)
class SwiftObjcRenamedObject: Object {
    @ManagedProperty var stringCol = ""
}

@objc(SwiftObjcRenamedObjectWithTotallyDifferentName)
class SwiftObjcArbitrarilyRenamedObject: Object {
    @ManagedProperty var boolCol = false
}

class SwiftCircleObject: Object {
    @ManagedProperty var obj: SwiftCircleObject?
    @ManagedProperty var array: List<SwiftCircleObject>
}

// Exists to serve as a superclass to `SwiftGenericPropsOrderingObject`
class SwiftGenericPropsOrderingParent: Object {
    var implicitlyIgnoredComputedProperty: Int { return 0 }
    let implicitlyIgnoredReadOnlyProperty: Int = 1
    @ManagedProperty var parentFirstList: List<SwiftIntObject>
    @ManagedProperty var parentFirstNumber = 0
    func parentFunction() -> Int { return parentFirstNumber + 1 }
    @ManagedProperty var parentSecondNumber = 1
    var parentComputedProp: String { return "hello world" }
}

// Used to verify that Swift properties (generic and otherwise) are detected properly and
// added to the schema in the correct order.
class SwiftGenericPropsOrderingObject: SwiftGenericPropsOrderingParent {
    func myFunction() -> Int { return firstNumber + secondNumber + thirdNumber }
    @objc dynamic var dynamicComputed: Int { return 999 }
    var firstIgnored = 999
    @ManagedProperty var dynamicIgnored = 999
    @ManagedProperty var firstNumber = 0                   // Managed property
    class func myClassFunction(x: Int, y: Int) -> Int { return x + y }
    var secondIgnored = 999
    lazy var lazyIgnored = 999
    @ManagedProperty var firstArray: List<SwiftStringObject>          // Managed property
    @ManagedProperty var secondNumber = 0                  // Managed property
    var computedProp: String { return "\(firstNumber), \(secondNumber), and \(thirdNumber)" }
    @ManagedProperty var secondArray: List<SwiftStringObject>         // Managed property
    override class func ignoredProperties() -> [String] {
        return ["firstIgnored", "dynamicIgnored", "secondIgnored", "thirdIgnored", "lazyIgnored", "dynamicLazyIgnored"]
    }
    @ManagedProperty var firstOptionalNumber: Int?      // Managed property
    var thirdIgnored = 999
    @objc dynamic lazy var dynamicLazyIgnored = 999
    @ManagedProperty(originProperty: "first") var firstLinking: LinkingObjects<SwiftGenericPropsOrderingHelper>
    @ManagedProperty(originProperty: "second") var secondLinking: LinkingObjects<SwiftGenericPropsOrderingHelper>
    @ManagedProperty var thirdNumber = 0                   // Managed property
    @ManagedProperty var secondOptionalNumber: Int?     // Managed property
}

// Only exists to allow linking object properties on `SwiftGenericPropsNotLastObject`.
class SwiftGenericPropsOrderingHelper: Object {
    @ManagedProperty var first: SwiftGenericPropsOrderingObject?
    @ManagedProperty var second: SwiftGenericPropsOrderingObject?
}

class SwiftRenamedProperties1: Object {
    @objc dynamic var propA = 0
    @objc dynamic var propB = ""
    let linking1 = LinkingObjects(fromType: LinkToSwiftRenamedProperties1.self, property: "linkA")
    let linking2 = LinkingObjects(fromType: LinkToSwiftRenamedProperties2.self, property: "linkD")

    override class func _realmObjectName() -> String { return "Swift Renamed Properties" }
    override class func _realmColumnNames() -> [String: String] {
        return ["propA": "prop 1", "propB": "prop 2"]
    }
}

class SwiftRenamedProperties2: Object {
    @objc dynamic var propC = 0
    @objc dynamic var propD = ""
    let linking1 = LinkingObjects(fromType: LinkToSwiftRenamedProperties1.self, property: "linkA")
    let linking2 = LinkingObjects(fromType: LinkToSwiftRenamedProperties2.self, property: "linkD")

    override class func _realmObjectName() -> String { return "Swift Renamed Properties" }
    override class func _realmColumnNames() -> [String: String] {
        return ["propC": "prop 1", "propD": "prop 2"]
    }
}

class LinkToSwiftRenamedProperties1: Object {
    @objc dynamic var linkA: SwiftRenamedProperties1?
    @objc dynamic var linkB: SwiftRenamedProperties2?
    let array1 = List<SwiftRenamedProperties1>()

    override class func _realmObjectName() -> String { return "Link To Swift Renamed Properties" }
    override class func _realmColumnNames() -> [String: String] {
        return ["linkA": "link 1", "linkB": "link 2", "array1": "array"]
    }
}

class LinkToSwiftRenamedProperties2: Object {
    @objc dynamic var linkC: SwiftRenamedProperties1?
    @objc dynamic var linkD: SwiftRenamedProperties2?
    let array2 = List<SwiftRenamedProperties2>()

    override class func _realmObjectName() -> String { return "Link To Swift Renamed Properties" }
    override class func _realmColumnNames() -> [String: String] {
        return ["linkC": "link 1", "linkD": "link 2", "array2": "array"]
    }
}

class EmbeddedParentObject: Object {
    @ManagedProperty var object: EmbeddedTreeObject1?
    @ManagedProperty var array: List<EmbeddedTreeObject1>
}

class EmbeddedPrimaryParentObject: Object {
    @ManagedProperty(primaryKey: true) var pk: Int = 0
    @ManagedProperty var object: EmbeddedTreeObject1?
    @ManagedProperty var array: List<EmbeddedTreeObject1>
}

protocol EmbeddedTreeObject: EmbeddedObject {
    var value: Int { get set }
}

class EmbeddedTreeObject1: EmbeddedObject, EmbeddedTreeObject {
    @ManagedProperty var value = 0
    @ManagedProperty var child: EmbeddedTreeObject2?
    @ManagedProperty var children: List<EmbeddedTreeObject2>

    @ManagedProperty(originProperty: "object") var parent1: LinkingObjects<EmbeddedParentObject>
    @ManagedProperty(originProperty: "array") var parent2: LinkingObjects<EmbeddedParentObject>
}

class EmbeddedTreeObject2: EmbeddedObject, EmbeddedTreeObject {
    @ManagedProperty var value = 0
    @ManagedProperty var child: EmbeddedTreeObject3?
    @ManagedProperty var children: List<EmbeddedTreeObject3>

    @ManagedProperty(originProperty: "child") var parent3: LinkingObjects<EmbeddedTreeObject1>
    @ManagedProperty(originProperty: "children") var parent4: LinkingObjects<EmbeddedTreeObject1>
}

class EmbeddedTreeObject3: EmbeddedObject, EmbeddedTreeObject {
    @ManagedProperty var value = 0

    @ManagedProperty(originProperty: "child") var parent3: LinkingObjects<EmbeddedTreeObject2>
    @ManagedProperty(originProperty: "children") var parent4: LinkingObjects<EmbeddedTreeObject2>
}
