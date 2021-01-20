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

extension Object: _RealmSchemaDiscoverable, _ManagedPropertyType {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        if !prop.optional && !prop.array {
            throwRealmException("Object property '\(prop.name)' must be marked as optional.")
        }
        if prop.optional && prop.array {
            throwRealmException("List<\(className())> property '\(prop.name)' must not be marked as optional.")
        }
        prop.type = .object
        prop.objectClassName = className()
    }

    public static func _rlmDefaultValue() -> Self { return Self() }

    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: UInt16) -> Self {
        fatalError("Non-optional Object properties are not allowed.")
    }

    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: UInt16) -> Self? {
//        return RLMGetSwiftPropertyObject(obj, key).map(dynamicBridgeCast)
//        FIXME: gives Assertion failed: (LocalSelf && "no local self metadata"), function getLocalSelfMetadata, file /src/swift-source/swift/lib/IRGen/GenHeap.cpp, line 1686.
        if let value = RLMGetSwiftPropertyObject(obj, key) {
            return (value as! Self)
        }
        return nil
    }

    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: UInt16, _ value: Object) {
        RLMSetSwiftPropertyObject(obj, key, value)
    }
}

extension EmbeddedObject: _RealmSchemaDiscoverable, _ManagedPropertyType {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        Object._rlmPopulateProperty(prop)
        prop.objectClassName = className()
    }

    public static func _rlmDefaultValue() -> Self { return Self() }

    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: UInt16) -> Self {
        fatalError("Non-optional EmbeddedObject properties are not allowed.")
    }

    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: UInt16) -> Self? {
        if let value = RLMGetSwiftPropertyObject(obj, key) {
            return (value as! Self)
        }
        return nil
    }

    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: UInt16, _ value: EmbeddedObject) {
        RLMSetSwiftPropertyObject(obj, key, value)
    }
}

extension List: _RealmSchemaDiscoverable where Element: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.array = true
        prop.swiftAccessor = ListAccessor<Element>.self
        Element._rlmPopulateProperty(prop)
    }
    public static func _rlmRequireObjc() -> Bool { return false }
}

extension List: _ManagedPropertyType where Element: _ManagedPropertyType {
    public static func _rlmDefaultValue() -> Self { return Self() }

    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: UInt16) -> Self {
        return Self(objc: RLMGetSwiftPropertyArray(obj, key))
    }

    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: UInt16) -> Self? {
        return Self(objc: RLMGetSwiftPropertyArray(obj, key))
    }

    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: UInt16, _ value: List) {
        let array = RLMGetSwiftPropertyArray(obj, key)
        if array.isEqual(value._rlmArray) { return }
        array.removeAllObjects()
        array.addObjects(value._rlmArray)
    }

    static public func _rlmSetAccessor(_ prop: RLMProperty) {
        prop.swiftAccessor = ManagedListAccessor<Element>.self
    }
}

extension LinkingObjects: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.array = true
        prop.type = .linkingObjects
        prop.objectClassName = Element.className()
        prop.swiftAccessor = LinkingObjectsAccessor<Element>.self
    }
    public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.linkOriginPropertyName = self.propertyName
    }
    public static func _rlmRequireObjc() -> Bool { return false }
}

extension LinkingObjects: _ManagedPropertyType where Element: _ManagedPropertyType {
    public static func _rlmDefaultValue() -> Self {
        fatalError("LinkingObjects properties must set the origin property name")
    }

    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: UInt16) -> LinkingObjects {
        let prop = RLMObjectBaseObjectSchema(obj)!.properties[Int(key)]
        return Self(propertyName: prop.name, handle: RLMLinkingObjectsHandle(object: obj, property: prop))
    }

    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: UInt16) -> LinkingObjects? {
        fatalError("LinkingObjects properties cannot be optional")
    }

    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: UInt16, _ value: LinkingObjects) {
        fatalError("LinkingObjects properties are read-only")
    }

    static public func _rlmSetAccessor(_ prop: RLMProperty) {
//        prop.swiftAccessor = ManagedLinkingObjectsAccessor<Element>.self
    }
}

extension Optional: _RealmSchemaDiscoverable where Wrapped: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.optional = true
        Wrapped._rlmPopulateProperty(prop)
    }
}

extension Optional: _ManagedPropertyType where Wrapped: _ManagedPropertyType {
    public static func _rlmDefaultValue() -> Self { return .none }
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: UInt16) -> Wrapped? {
        return Wrapped._rlmGetPropertyOptional(obj, key)
    }
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: UInt16) -> Wrapped?? {
        fatalError("Double-optional properties are not supported")
    }
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: UInt16, _ value: Wrapped?) {
        if let value = value {
            Wrapped._rlmSetProperty(obj, key, value)
        } else {
            RLMSetSwiftPropertyNil(obj, key)
        }
    }
}

extension Optional: PrimaryKeyProperty where Wrapped: PrimaryKeyProperty {
}

extension Optional: IndexableProperty where Wrapped: IndexableProperty {
}

extension RealmOptional: _RealmSchemaDiscoverable where Value: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        Value._rlmPopulateProperty(prop)
        prop.optional = true
        prop.swiftAccessor = RealmOptionalAccessor<Value>.self
    }
    public static func _rlmRequireObjc() -> Bool { return false }
}

extension NSString: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.type = .string
    }
}

extension NSData: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.type = .data
    }
}

extension NSDate: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.type = .date
    }
}

extension RawRepresentable where RawValue: _RealmSchemaDiscoverable {
    static public func _rlmPopulateProperty(_ prop: RLMProperty) {
        RawValue._rlmPopulateProperty(prop)
    }
}

extension RawRepresentable where Self: _ManagedPropertyType, RawValue: _ManagedPropertyType {
    public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Self {
        return Self(rawValue: RawValue._rlmGetProperty(obj, key))!
    }
    public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Self? {
        return RawValue._rlmGetPropertyOptional(obj, key).flatMap(Self.init)
    }
    public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Self) {
        RawValue._rlmSetProperty(obj, key, value.rawValue)
    }
    public static func _rlmSetAccessor(_ prop: RLMProperty) {
        prop.swiftAccessor = ManagedEnumAccessor<Self>.self
    }
}
