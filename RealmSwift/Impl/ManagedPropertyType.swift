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

public typealias PropertyKey = UInt16

public protocol _DiscoverableManagedProperty: _RealmSchemaDiscoverable {
}

public protocol _ManagedPropertyType: _RealmSchemaDiscoverable {
    static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Self
    static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Self?
    static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Self)
    static func _rlmDefaultValue() -> Self
    static func _rlmSetAccessor(_ prop: RLMProperty)
    static func _rlmCoerce(_ value: Any) -> Self
}
extension _ManagedPropertyType {
    public static var _className: String? { nil }
    public static func _rlmDefaultValue() -> Self { fatalError() }
    static public func _rlmSetAccessor(_ prop: RLMProperty) {
        prop.swiftAccessor = ManagedPropertyAccessor<Self>.self
    }
    static public func _rlmCoerce(_ value: Any) -> Self {
        return value as! Self
    }
}
