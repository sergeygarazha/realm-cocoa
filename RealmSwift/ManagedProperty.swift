////////////////////////////////////////////////////////////////////////////
//
// Copyright 2019 Realm Inc.
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

public protocol IndexableProperty {
}
public protocol PrimaryKeyProperty {
}

private protocol NeedsParentForObservation {
    func setParent(_ object: RLMObjectBase, _ property: RLMProperty)
}
extension List: NeedsParentForObservation {
    fileprivate func setParent(_ object: RLMObjectBase, _ property: RLMProperty) {
        RLMSetArrayParent(_rlmArray, object, property)
    }
}

private enum PropertyStorage<T> {
    case unmanaged(value: T, indexed: Bool = false, primary: Bool = false)
    case unmanagedNoDefault(indexed: Bool = false, primary: Bool = false)
    case unmanagedObserved(value: T, key: PropertyKey)
    case managed(key: PropertyKey)
    case managedCached(value: T, key: PropertyKey)
}

@propertyWrapper
public struct ManagedProperty<Value: _ManagedPropertyType> {
    private var storage: PropertyStorage<Value>
    public var _accessor: RLMManagedPropertyAccessor.Type {
        return ManagedPropertyAccessor<Value>.self
    }

    @available(*, unavailable)
    public var wrappedValue: Value {
        get { fatalError("called wrappedValue getter") }
        set { fatalError("called wrappedValue setter") }
    }

    public init() {
        storage = .unmanagedNoDefault(indexed: false, primary: false)
    }
    public init(wrappedValue value: Value) {
        storage = .unmanaged(value: value, indexed: false, primary: false)
    }

    public static subscript<EnclosingSelf: ObjectBase>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
        ) -> Value {
        get {
            return observed[keyPath: storageKeyPath].get(observed)
        }
        set {
            observed[keyPath: storageKeyPath].set(observed, value: newValue)
        }
    }

    internal mutating func initialize(_ object: ObjectBase, key: PropertyKey) {
        storage = .managed(key: key)
    }

    internal mutating func get(_ object: ObjectBase) -> Value {
        switch storage {
        case let .unmanaged(value, _, _):
            return value
        case .unmanagedNoDefault:
            let value = Value._rlmDefaultValue()
            storage = .unmanaged(value: value)
            return value
        case let .unmanagedObserved(value, _):
            return value
        case let .managed(key):
            let v = Value._rlmGetProperty(object, key)
            // FIXME: real check for this
            if v is NeedsParentForObservation {
                storage = .managedCached(value: v, key: key)
            }
            return v
        case let .managedCached(value, _):
            return value
        }
    }

    internal mutating func set(_ object: ObjectBase, value: Value) {
        switch storage {
        case let .unmanagedObserved(_, key):
            let name = RLMObjectBaseObjectSchema(object)!.properties[Int(key)].name
            object.willChangeValue(forKey: name)
            storage = .unmanagedObserved(value: value, key: key)
            object.didChangeValue(forKey: name)
        case .managed(let key), .managedCached(_, let key):
            Value._rlmSetProperty(object, key, value)
        case .unmanaged, .unmanagedNoDefault:
            storage = .unmanaged(value: value, indexed: false, primary: false)
        }
    }

    internal mutating func observe(_ object: ObjectBase, property: RLMProperty) {
        let value: Value
        switch storage {
        case let .unmanaged(v, _, _):
            value = v
        case .unmanagedNoDefault:
            value = Value._rlmDefaultValue()
        case .unmanagedObserved, .managed, .managedCached:
            return
        }
        if let value = value as? NeedsParentForObservation {
            value.setParent(object, property)
        }
        storage = .unmanagedObserved(value: value, key: PropertyKey(property.index))
    }
}

extension ManagedProperty: _DiscoverableManagedProperty where Value: _ManagedPropertyType {
    public static func _rlmPopulateProperty(_ prop: RLMProperty) {
        prop.name = String(prop.name.dropFirst())
        Value._rlmPopulateProperty(prop)
        Value._rlmSetAccessor(prop)
    }
    public func _rlmPopulateProperty(_ prop: RLMProperty) {
        switch storage {
        case let .unmanaged(value, indexed, primary):
            value._rlmPopulateProperty(prop)
            prop.indexed = indexed || primary
            prop.isPrimary = primary
        case let .unmanagedNoDefault(indexed, primary):
            prop.indexed = indexed || primary
            prop.isPrimary = primary
        default:
            return
        }
    }
    public static func _rlmRequireObjc() -> Bool { false }
}

extension ManagedProperty where Value: IndexableProperty {
    public init(indexed: Bool) {
        storage = .unmanagedNoDefault(indexed: indexed)
    }
    public init(wrappedValue value: Value, indexed: Bool) {
        storage = .unmanaged(value: value, indexed: indexed)
    }
}

extension ManagedProperty where Value: PrimaryKeyProperty {
    public init(primaryKey: Bool) {
        storage = .unmanagedNoDefault(primary: primaryKey)
    }
    public init(wrappedValue value: Value, primaryKey: Bool) {
        storage = .unmanaged(value: value, primary: primaryKey)
    }
}

public protocol LinkingObjectsProtocol {
    init(fromType: Element.Type, property: String)
    associatedtype Element
}
extension ManagedProperty where Value: LinkingObjectsProtocol {
    public init(originProperty: String) {
        self.init(wrappedValue: Value(fromType: Value.Element.self, property: originProperty))
    }
}
extension LinkingObjects: LinkingObjectsProtocol {
}
