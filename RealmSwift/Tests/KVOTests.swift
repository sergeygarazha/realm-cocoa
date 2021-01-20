////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
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

import XCTest
import RealmSwift

var pkCounter = 0
func nextPrimaryKey() -> Int {
    pkCounter += 1
    return pkCounter
}

class SwiftKVOObject: Object {
    @ManagedProperty(primaryKey: true) var pk = nextPrimaryKey() // primary key for equality
    var ignored: Int = 0

    @ManagedProperty var boolCol: Bool = false
    @ManagedProperty var int8Col: Int8 = 1
    @ManagedProperty var int16Col: Int16 = 2
    @ManagedProperty var int32Col: Int32 = 3
    @ManagedProperty var int64Col: Int64 = 4
    @ManagedProperty var floatCol: Float = 5
    @ManagedProperty var doubleCol: Double = 6
    @ManagedProperty var stringCol: String = ""
    @ManagedProperty var binaryCol: Data = Data()
    @ManagedProperty var dateCol: Date = Date(timeIntervalSince1970: 0)
    @ManagedProperty var decimalCol: Decimal128 = Decimal128(number: 1)
    @ManagedProperty var objectIdCol = ObjectId()
    @ManagedProperty var objectCol: SwiftKVOObject?

    @ManagedProperty var arrayCol: List<SwiftKVOObject>
    @ManagedProperty var optIntCol: Int?
    @ManagedProperty var optFloatCol: Float?
    @ManagedProperty var optDoubleCol: Double?
    @ManagedProperty var optBoolCol: Bool?
    @ManagedProperty var optStringCol: String?
    @ManagedProperty var optBinaryCol: Data?
    @ManagedProperty var optDateCol: Date?
    @ManagedProperty var optDecimalCol: Decimal128?
    @ManagedProperty var optObjectIdCol: ObjectId?

    @ManagedProperty var arrayBool: List<Bool>
    @ManagedProperty var arrayInt8: List<Int8>
    @ManagedProperty var arrayInt16: List<Int16>
    @ManagedProperty var arrayInt32: List<Int32>
    @ManagedProperty var arrayInt64: List<Int64>
    @ManagedProperty var arrayFloat: List<Float>
    @ManagedProperty var arrayDouble: List<Double>
    @ManagedProperty var arrayString: List<String>
    @ManagedProperty var arrayBinary: List<Data>
    @ManagedProperty var arrayDate: List<Date>
    @ManagedProperty var arrayDecimal: List<Decimal128>
    @ManagedProperty var arrayObjectId: List<ObjectId>

    @ManagedProperty var arrayOptBool: List<Bool?>
    @ManagedProperty var arrayOptInt8: List<Int8?>
    @ManagedProperty var arrayOptInt16: List<Int16?>
    @ManagedProperty var arrayOptInt32: List<Int32?>
    @ManagedProperty var arrayOptInt64: List<Int64?>
    @ManagedProperty var arrayOptFloat: List<Float?>
    @ManagedProperty var arrayOptDouble: List<Double?>
    @ManagedProperty var arrayOptString: List<String?>
    @ManagedProperty var arrayOptBinary: List<Data?>
    @ManagedProperty var arrayOptDate: List<Date?>
    @ManagedProperty var arrayOptDecimal: List<Decimal128?>
    @ManagedProperty var arrayOptObjectId: List<ObjectId?>
}

// Most of the testing of KVO functionality is done in the obj-c tests
// These tests just verify that it also works on Swift types
class KVOTests: TestCase {
    var realm: Realm! = nil

    override func setUp() {
        super.setUp()
        realm = try! Realm()
        realm.beginWrite()
    }

    override func tearDown() {
        realm.cancelWrite()
        realm = nil
        super.tearDown()
    }

    var changeDictionary: [NSKeyValueChangeKey: Any]?

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        changeDictionary = change
    }

    // swiftlint:disable:next cyclomatic_complexity
    func observeChange<T: Equatable>(_ obj: SwiftKVOObject, _ key: String, _ old: T?, _ new: T?,
                                     fileName: StaticString = #file, lineNumber: UInt = #line, _ block: () -> Void) {
        let kvoOptions: NSKeyValueObservingOptions = [.old, .new]
        obj.addObserver(self, forKeyPath: key, options: kvoOptions, context: nil)
        block()
        obj.removeObserver(self, forKeyPath: key)

        XCTAssert(changeDictionary != nil, "Did not get a notification", file: (fileName), line: lineNumber)
        guard changeDictionary != nil else { return }

        let actualOld = changeDictionary![.oldKey]! as? T
        let actualNew = changeDictionary![.newKey]! as? T

        XCTAssert(old == actualOld,
                  "Old value: expected \(String(describing: old)), got \(String(describing: actualOld))",
                  file: (fileName), line: lineNumber)
        XCTAssert(new == actualNew,
                  "New value: expected \(String(describing: new)), got \(String(describing: actualNew))",
                  file: (fileName), line: lineNumber)

        changeDictionary = nil
    }

    func observeChange<T: Equatable>(_ obj: SwiftKVOObject, _ keyPath: KeyPath<SwiftKVOObject, T>, _ old: T, _ new: T,
                                     fileName: StaticString = #file, lineNumber: UInt = #line, _ block: () -> Void) {
        let kvoOptions: NSKeyValueObservingOptions = [.old, .new]
        var gotNotification = false
        let observation = obj.observe(keyPath, options: kvoOptions) { _, change in
            XCTAssertEqual(change.oldValue, old, file: (fileName), line: lineNumber)
            XCTAssertEqual(change.newValue, new, file: (fileName), line: lineNumber)
            gotNotification = true
        }

        block()
        observation.invalidate()

        XCTAssertTrue(gotNotification, file: (fileName), line: lineNumber)
    }

    func observeChange<T: Equatable>(_ obj: SwiftKVOObject, _ keyPath: KeyPath<SwiftKVOObject, T?>, _ old: T?, _ new: T?,
                                     fileName: StaticString = #file, lineNumber: UInt = #line, _ block: () -> Void) {
        let kvoOptions: NSKeyValueObservingOptions = [.old, .new]
        var gotNotification = false
        let observation = obj.observe(keyPath, options: kvoOptions) { _, change in
            if let oldValue = change.oldValue {
                XCTAssertEqual(oldValue, old, file: (fileName), line: lineNumber)
            } else {
                XCTAssertNil(old, file: (fileName), line: lineNumber)
            }
            if let newValue = change.newValue {
                XCTAssertEqual(newValue, new, file: (fileName), line: lineNumber)
            } else {
                XCTAssertNil(new, file: (fileName), line: lineNumber)
            }
            gotNotification = true
        }

        block()
        observation.invalidate()

        XCTAssertTrue(gotNotification, file: (fileName), line: lineNumber)
    }

    func observeListChange(_ obj: NSObject, _ key: String, _ kind: NSKeyValueChange, _ indexes: NSIndexSet = NSIndexSet(index: 0),
                           fileName: StaticString = #file, lineNumber: UInt = #line, _ block: () -> Void) {
        obj.addObserver(self, forKeyPath: key, options: [.old, .new], context: nil)
        block()
        obj.removeObserver(self, forKeyPath: key)
        XCTAssert(changeDictionary != nil, "Did not get a notification", file: (fileName), line: lineNumber)
        guard changeDictionary != nil else { return }

        let actualKind = NSKeyValueChange(rawValue: (changeDictionary![NSKeyValueChangeKey.kindKey] as! NSNumber).uintValue)!
        let actualIndexes = changeDictionary![NSKeyValueChangeKey.indexesKey]! as! NSIndexSet
        XCTAssert(actualKind == kind, "Change kind: expected \(kind), got \(actualKind)", file: (fileName),
                  line: lineNumber)
        XCTAssert(actualIndexes.isEqual(indexes), "Changed indexes: expected \(indexes), got \(actualIndexes)",
                  file: (fileName), line: lineNumber)

        changeDictionary = nil
    }

    func getObject(_ obj: SwiftKVOObject) -> (SwiftKVOObject, SwiftKVOObject) {
        return (obj, obj)
    }

    // Actual tests follow

    func testAllPropertyTypes() {
        let (obj, obs) = getObject(SwiftKVOObject())

        observeChange(obs, "boolCol", false, true) { obj.boolCol = true }
        observeChange(obs, "int8Col", 1 as Int8, 10) { obj.int8Col = 10 }
        observeChange(obs, "int16Col", 2 as Int16, 10) { obj.int16Col = 10 }
        observeChange(obs, "int32Col", 3 as Int32, 10) { obj.int32Col = 10 }
        observeChange(obs, "int64Col", 4 as Int64, 10) { obj.int64Col = 10 }
        observeChange(obs, "floatCol", 5 as Float, 10) { obj.floatCol = 10 }
        observeChange(obs, "doubleCol", 6 as Double, 10) { obj.doubleCol = 10 }
        observeChange(obs, "stringCol", "", "abc") { obj.stringCol = "abc" }
        observeChange(obs, "objectCol", nil, obj) { obj.objectCol = obj }

        let data = "abc".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        observeChange(obs, "binaryCol", Data(), data) { obj.binaryCol = data }

        let date = Date(timeIntervalSince1970: 1)
        observeChange(obs, "dateCol", Date(timeIntervalSince1970: 0), date) { obj.dateCol = date }

        let decimal = Decimal128(number: 2)
        observeChange(obs, "decimalCol", Decimal128(number: 1), decimal) { obj.decimalCol = decimal }

        let oldObjectId = obj.objectIdCol
        let objectId = ObjectId()
        observeChange(obs, "objectIdCol", oldObjectId, objectId) { obj.objectIdCol = objectId }

        observeListChange(obs, "arrayCol", .insertion) { obj.arrayCol.append(obj) }
        observeListChange(obs, "arrayCol", .removal) { obj.arrayCol.removeAll() }

        observeChange(obs, "optIntCol", nil, 10) { obj.optIntCol = 10 }
        observeChange(obs, "optFloatCol", nil, 10.0) { obj.optFloatCol = 10 }
        observeChange(obs, "optDoubleCol", nil, 10.0) { obj.optDoubleCol = 10 }
        observeChange(obs, "optBoolCol", nil, true) { obj.optBoolCol = true }
        observeChange(obs, "optStringCol", nil, "abc") { obj.optStringCol = "abc" }
        observeChange(obs, "optBinaryCol", nil, data) { obj.optBinaryCol = data }
        observeChange(obs, "optDateCol", nil, date) { obj.optDateCol = date }
        observeChange(obs, "optDecimalCol", nil, decimal) { obj.optDecimalCol = decimal }
        observeChange(obs, "optObjectIdCol", nil, objectId) { obj.optObjectIdCol = objectId }

        observeChange(obs, "optIntCol", 10, nil) { obj.optIntCol = nil }
        observeChange(obs, "optFloatCol", 10.0, nil) { obj.optFloatCol = nil }
        observeChange(obs, "optDoubleCol", 10.0, nil) { obj.optDoubleCol = nil }
        observeChange(obs, "optBoolCol", true, nil) { obj.optBoolCol = nil }
        observeChange(obs, "optStringCol", "abc", nil) { obj.optStringCol = nil }
        observeChange(obs, "optBinaryCol", data, nil) { obj.optBinaryCol = nil }
        observeChange(obs, "optDateCol", date, nil) { obj.optDateCol = nil }
        observeChange(obs, "optDecimalCol", decimal, nil) { obj.optDecimalCol = nil }
        observeChange(obs, "optObjectIdCol", objectId, nil) { obj.optObjectIdCol = nil }

        observeListChange(obs, "arrayBool", .insertion) { obj.arrayBool.append(true) }
        observeListChange(obs, "arrayInt8", .insertion) { obj.arrayInt8.append(10) }
        observeListChange(obs, "arrayInt16", .insertion) { obj.arrayInt16.append(10) }
        observeListChange(obs, "arrayInt32", .insertion) { obj.arrayInt32.append(10) }
        observeListChange(obs, "arrayInt64", .insertion) { obj.arrayInt64.append(10) }
        observeListChange(obs, "arrayFloat", .insertion) { obj.arrayFloat.append(10) }
        observeListChange(obs, "arrayDouble", .insertion) { obj.arrayDouble.append(10) }
        observeListChange(obs, "arrayString", .insertion) { obj.arrayString.append("abc") }
        observeListChange(obs, "arrayDecimal", .insertion) { obj.arrayDecimal.append(decimal) }
        observeListChange(obs, "arrayObjectId", .insertion) { obj.arrayObjectId.append(objectId) }

        observeListChange(obs, "arrayOptBool", .insertion) { obj.arrayOptBool.append(true) }
        observeListChange(obs, "arrayOptInt8", .insertion) { obj.arrayOptInt8.append(10) }
        observeListChange(obs, "arrayOptInt16", .insertion) { obj.arrayOptInt16.append(10) }
        observeListChange(obs, "arrayOptInt32", .insertion) { obj.arrayOptInt32.append(10) }
        observeListChange(obs, "arrayOptInt64", .insertion) { obj.arrayOptInt64.append(10) }
        observeListChange(obs, "arrayOptFloat", .insertion) { obj.arrayOptFloat.append(10) }
        observeListChange(obs, "arrayOptDouble", .insertion) { obj.arrayOptDouble.append(10) }
        observeListChange(obs, "arrayOptString", .insertion) { obj.arrayOptString.append("abc") }
        observeListChange(obs, "arrayOptBinary", .insertion) { obj.arrayOptBinary.append(data) }
        observeListChange(obs, "arrayOptDate", .insertion) { obj.arrayOptDate.append(date) }
        observeListChange(obs, "arrayOptDecimal", .insertion) { obj.arrayOptDecimal.append(decimal) }
        observeListChange(obs, "arrayOptObjectId", .insertion) { obj.arrayOptObjectId.append(objectId) }

        observeListChange(obs, "arrayOptBool", .insertion) { obj.arrayOptBool.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptInt8", .insertion) { obj.arrayOptInt8.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptInt16", .insertion) { obj.arrayOptInt16.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptInt32", .insertion) { obj.arrayOptInt32.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptInt64", .insertion) { obj.arrayOptInt64.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptFloat", .insertion) { obj.arrayOptFloat.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptDouble", .insertion) { obj.arrayOptDouble.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptString", .insertion) { obj.arrayOptString.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptDate", .insertion) { obj.arrayOptDate.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptBinary", .insertion) { obj.arrayOptBinary.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptDecimal", .insertion) { obj.arrayOptDecimal.insert(nil, at: 0) }
        observeListChange(obs, "arrayOptObjectId", .insertion) { obj.arrayOptObjectId.insert(nil, at: 0) }

        if obs.realm == nil {
            return
        }

        observeChange(obs, "invalidated", false, true) {
            self.realm.delete(obj)
        }

        let (obj2, obs2) = getObject(SwiftKVOObject())
        observeChange(obs2, "arrayCol.invalidated", false, true) {
            self.realm.delete(obj2)
        }
    }

    func testTypedObservation() {
        return;
        let (obj, obs) = getObject(SwiftKVOObject())

        // Swift 5.2+ warns when a literal keypath to a non-@objc property is
        // passed to observe(). This only works when it's passed directly and
        // not via a helper, so make sure we aren't triggering this warning on
        // any property types.
        _ = obs.observe(\.boolCol) { _, _ in }
        _ = obs.observe(\.int8Col) { _, _ in }
        _ = obs.observe(\.int16Col) { _, _ in }
        _ = obs.observe(\.int32Col) { _, _ in }
        _ = obs.observe(\.int64Col) { _, _ in }
        _ = obs.observe(\.floatCol) { _, _ in }
        _ = obs.observe(\.doubleCol) { _, _ in }
        _ = obs.observe(\.stringCol) { _, _ in }
        _ = obs.observe(\.binaryCol) { _, _ in }
        _ = obs.observe(\.dateCol) { _, _ in }
        _ = obs.observe(\.objectCol) { _, _ in }
        _ = obs.observe(\.optStringCol) { _, _ in }
        _ = obs.observe(\.optBinaryCol) { _, _ in }
        _ = obs.observe(\.optDateCol) { _, _ in }
        _ = obs.observe(\.optStringCol) { _, _ in }
        _ = obs.observe(\.optBinaryCol) { _, _ in }
        _ = obs.observe(\.optDateCol) { _, _ in }
        _ = obs.observe(\.isInvalidated) { _, _ in }

        observeChange(obs, \.boolCol, false, true) { obj.boolCol = true }

        observeChange(obs, \.int8Col, 1 as Int8, 10 as Int8) { obj.int8Col = 10 }
        observeChange(obs, \.int16Col, 2 as Int16, 10 as Int16) { obj.int16Col = 10 }
        observeChange(obs, \.int32Col, 3 as Int32, 10 as Int32) { obj.int32Col = 10 }
        observeChange(obs, \.int64Col, 4 as Int64, 10 as Int64) { obj.int64Col = 10 }
        observeChange(obs, \.floatCol, 5 as Float, 10 as Float) { obj.floatCol = 10 }
        observeChange(obs, \.doubleCol, 6 as Double, 10 as Double) { obj.doubleCol = 10 }
        observeChange(obs, \.stringCol, "", "abc") { obj.stringCol = "abc" }

        let data = "abc".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        observeChange(obs, \.binaryCol, Data(), data) { obj.binaryCol = data }

        let date = Date(timeIntervalSince1970: 1)
        observeChange(obs, \.dateCol, Date(timeIntervalSince1970: 0), date) { obj.dateCol = date }

        let decimal = Decimal128(number: 2)
        observeChange(obs, \.decimalCol, Decimal128(number: 1), decimal) { obj.decimalCol = decimal }

        let oldObjectId = obj.objectIdCol
        let objectId = ObjectId()
        observeChange(obs, \.objectIdCol, oldObjectId, objectId) { obj.objectIdCol = objectId }

        observeChange(obs, \.objectCol, nil, obj) { obj.objectCol = obj }

        observeChange(obs, \.optStringCol, nil, "abc") { obj.optStringCol = "abc" }
        observeChange(obs, \.optBinaryCol, nil, data) { obj.optBinaryCol = data }
        observeChange(obs, \.optDateCol, nil, date) { obj.optDateCol = date }
        observeChange(obs, \.optDecimalCol, nil, decimal) { obj.optDecimalCol = decimal }
        observeChange(obs, \.optObjectIdCol, nil, objectId) { obj.optObjectIdCol = objectId }

        observeChange(obs, \.optStringCol, "abc", nil) { obj.optStringCol = nil }
        observeChange(obs, \.optBinaryCol, data, nil) { obj.optBinaryCol = nil }
        observeChange(obs, \.optDateCol, date, nil) { obj.optDateCol = nil }
        observeChange(obs, \.optDecimalCol, decimal, nil) { obj.optDecimalCol = nil }
        observeChange(obs, \.optObjectIdCol, objectId, nil) { obj.optObjectIdCol = nil }

        if obs.realm == nil {
            return
        }

        observeChange(obs, \.isInvalidated, false, true) {
            self.realm.delete(obj)
        }
    }

    func testReadSharedSchemaFromObservedObject() {
        let obj = SwiftKVOObject()
        obj.addObserver(self, forKeyPath: "boolCol", options: [.old, .new], context: nil)
        XCTAssertEqual(type(of: obj).sharedSchema(), SwiftKVOObject.sharedSchema())
        obj.removeObserver(self, forKeyPath: "boolCol")
    }
}

class KVOPersistedTests: KVOTests {
    override func getObject(_ obj: SwiftKVOObject) -> (SwiftKVOObject, SwiftKVOObject) {
        realm.add(obj)
        return (obj, obj)
    }
}

class KVOMultipleAccessorsTests: KVOTests {
    override func getObject(_ obj: SwiftKVOObject) -> (SwiftKVOObject, SwiftKVOObject) {
        realm.add(obj)
        return (obj, realm.object(ofType: SwiftKVOObject.self, forPrimaryKey: obj.pk)!)
    }
}
