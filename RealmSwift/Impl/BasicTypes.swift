////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

import Realm
import Realm.Private

extension Int: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .int
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Int {
        return Int(RLMGetSwiftPropertyInt64(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Int? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyInt64Optional(obj, key, &gotValue)
         return gotValue ? Int(ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Int) {
        RLMSetSwiftPropertyInt64(obj, key, Int64(value))
    }
}

extension Int8: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .int
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Int8 {
        return Int8(RLMGetSwiftPropertyInt64(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Int8? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyInt64Optional(obj, key, &gotValue)
         return gotValue ? Int8(ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Int8) {
        RLMSetSwiftPropertyInt64(obj, key, Int64(value))
    }
}

extension Int16: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .int
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Int16 {
        return Int16(RLMGetSwiftPropertyInt64(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Int16? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyInt64Optional(obj, key, &gotValue)
         return gotValue ? Int16(ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Int16) {
        RLMSetSwiftPropertyInt64(obj, key, Int64(value))
    }
}

extension Int32: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .int
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Int32 {
        return Int32(RLMGetSwiftPropertyInt64(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Int32? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyInt64Optional(obj, key, &gotValue)
         return gotValue ? Int32(ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Int32) {
        RLMSetSwiftPropertyInt64(obj, key, Int64(value))
    }
}

extension Int64: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .int
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Int64 {
        return Int64(RLMGetSwiftPropertyInt64(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Int64? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyInt64Optional(obj, key, &gotValue)
         return gotValue ? Int64(ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Int64) {
        RLMSetSwiftPropertyInt64(obj, key, Int64(value))
    }
}

extension Bool: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .bool
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Bool {
        return (RLMGetSwiftPropertyBool(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Bool? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyBoolOptional(obj, key, &gotValue)
         return gotValue ? (ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Bool) {
        RLMSetSwiftPropertyBool(obj, key, (value))
    }
}

extension Float: _RealmSchemaDiscoverable, _ManagedPropertyType {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .float
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Float {
        return (RLMGetSwiftPropertyFloat(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Float? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyFloatOptional(obj, key, &gotValue)
         return gotValue ? (ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Float) {
        RLMSetSwiftPropertyFloat(obj, key, (value))
    }
}

extension Double: _RealmSchemaDiscoverable, _ManagedPropertyType {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .double
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Double {
        return (RLMGetSwiftPropertyDouble(obj, key))
    }

    @inlinable
     public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Double? {
         var gotValue = false
         let ret = RLMGetSwiftPropertyDoubleOptional(obj, key, &gotValue)
         return gotValue ? (ret) : nil
     }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Double) {
        RLMSetSwiftPropertyDouble(obj, key, (value))
    }
}

extension String: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .string
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> String {
        return (RLMGetSwiftPropertyString(obj, key))
    }

    @inlinable
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> String? {
        return (RLMGetSwiftPropertyString(obj, key))
    }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: String) {
        RLMSetSwiftPropertyString(obj, key, (value))
    }
}

extension Data: _RealmSchemaDiscoverable, _ManagedPropertyType {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .data
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Data {
        return (RLMGetSwiftPropertyData(obj, key))
    }

    @inlinable
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Data? {
        return (RLMGetSwiftPropertyData(obj, key))
    }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Data) {
        RLMSetSwiftPropertyData(obj, key, (value))
    }
}

extension ObjectId: _RealmSchemaDiscoverable, _ManagedPropertyType, PrimaryKeyProperty, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .objectId
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> ObjectId {
        return RLMGetSwiftPropertyObjectId(obj, key) as! ObjectId
    }

    @inlinable
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> ObjectId? {
        return RLMGetSwiftPropertyObjectId(obj, key).map(dynamicBridgeCast)
    }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: ObjectId) {
        RLMSetSwiftPropertyObjectId(obj, key, (value))
    }
}

extension Decimal128: _RealmSchemaDiscoverable, _ManagedPropertyType {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .decimal128
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Decimal128 {
        return RLMGetSwiftPropertyDecimal128(obj, key) as! Decimal128
    }

    @inlinable
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Decimal128? {
        return RLMGetSwiftPropertyDecimal128(obj, key).map(dynamicBridgeCast)
    }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Decimal128) {
        RLMSetSwiftPropertyDecimal128(obj, key, (value))
    }
}

extension Date: _RealmSchemaDiscoverable, _ManagedPropertyType, IndexableProperty {
    public static func _rlmPopulateProperty(_ property: RLMProperty) {
        property.type = .date
    }

    @inlinable
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Date {
        return (RLMGetSwiftPropertyDate(obj, key))
    }

    @inlinable
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Date? {
        return (RLMGetSwiftPropertyDate(obj, key))
    }

    @inlinable
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Date) {
        RLMSetSwiftPropertyDate(obj, key, (value))
    }
}
