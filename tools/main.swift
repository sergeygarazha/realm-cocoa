//
//  GeneratePropertyTypes.swift
//  Realm
//
//  Created by Thomas Goyne on 4/8/21.
//  Copyright © 2021 Realm. All rights reserved.
//

import Foundation

let intSizes = ["Int", "Int8", "Int16", "Int32", "Int64"]
let nonIntPrimitives = ["Bool", "Float", "Double"]
let objectTypes = ["String", "Data", "ObjectId", "Decimal128", "Date"]

//func writeIfModified(to: URL, )

//guard CommandLine.argc == 2 else {
//    print("usage: GeneratePropertyTypes output-root")
//    exit(1)
//}
//let outputRoot = CommandLine.arguments[1]

func emitHeader() {
    print("""
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
    """)
}

func emitPopulateProperty(type: String, propertyType: String) {
    print("""

        extension \(type): _RealmSchemaDiscoverable, _ManagedPropertyType {
            public static func _rlmPopulateProperty(_ property: RLMProperty) {
                property.type = .\(propertyType)
            }
        """)
}

func emitGetter(type: String, convertedType: String? = nil) {
    let cast = convertedType != nil ? type : ""
    let convertedType = convertedType ?? type
    print("""

            @inlinable
            public static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> \(type) {
                return \(cast)(RLMGetSwiftProperty\(convertedType)(obj, key))
            }
        """)
}

func emitOptionalGetter(type: String, convertedType: String? = nil) {
    let cast = convertedType != nil ? type : ""
    let convertedType = convertedType ?? type
    print("""

            @inlinable
            public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> \(type)? {
                return \(cast)(RLMGetSwiftProperty\(convertedType)(obj, key))
            }
        """)
}

func emitOptionalPrimitiveGetter(type: String, convertedType: String? = nil) {
    let cast = convertedType != nil ? type : ""
    let convertedType = convertedType ?? type
    print("""

            @inlinable
             public static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> \(type)? {
                 var gotValue = false
                 let ret = RLMGetSwiftProperty\(convertedType)Optional(obj, key, &gotValue)
                 return gotValue ? \(cast)(ret) : nil
             }
        """)
}

func emitSetter(type: String, convertedType: String? = nil) {
    let cast = convertedType ?? ""
    let convertedType = convertedType ?? type
    print("""

            @inlinable
            public static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: \(type)) {
                RLMSetSwiftProperty\(convertedType)(obj, key, \(cast)(value))
            }
        """)
}
func emitFooter() {
    print("}")
}

func writeFile() {
    emitHeader()
    for type in intSizes {
        emitPopulateProperty(type: type, propertyType: "int")
        emitGetter(type: type, convertedType: "Int64")
        emitOptionalPrimitiveGetter(type: type, convertedType: "Int64")
        emitSetter(type: type, convertedType: "Int64")
        emitFooter()
    }
    for type in nonIntPrimitives {
        emitPopulateProperty(type: type, propertyType: type.lowercased())
        emitGetter(type: type)
        emitOptionalPrimitiveGetter(type: type)
        emitSetter(type: type)
        emitFooter()
    }
    for type in objectTypes {
        emitPopulateProperty(type: type, propertyType: type.lowercased())
        emitGetter(type: type)
        emitOptionalGetter(type: type)
        emitSetter(type: type)
        emitFooter()
    }
}

writeFile()
