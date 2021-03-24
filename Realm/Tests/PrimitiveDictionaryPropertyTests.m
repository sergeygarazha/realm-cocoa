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

#import "RLMTestCase.h"

static NSDate *date(int i) {
    return [NSDate dateWithTimeIntervalSince1970:i];
}
static NSData *data(int i) {
    return [NSData dataWithBytesNoCopy:calloc(i, 1) length:i freeWhenDone:YES];
}
static RLMDecimal128 *decimal128(int i) {
    return [RLMDecimal128 decimalWithNumber:@(i)];
}
static NSMutableArray *objectIds;
static RLMObjectId *objectId(NSUInteger i) {
    if (!objectIds) {
        objectIds = [NSMutableArray new];
    }
    while (i >= objectIds.count) {
        [objectIds addObject:RLMObjectId.objectId];
    }
    return objectIds[i];
}
static NSUUID *uuid(NSString *uuidString) {
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}
static void count(NSArray *values, double *sum, NSUInteger *count) {
    for (id value in values) {
        if (value != NSNull.null) {
            ++*count;
            *sum += [value doubleValue];
        }
    }
}
static double sum(NSDictionary *dictionary) {
    NSArray *values = dictionary.allValues;
    double sum = 0;
    NSUInteger c = 0;
    count(values, &sum, &c);
    return sum;
}
static double average(NSDictionary *dictionary) {
    NSArray *values = dictionary.allValues;
    double sum = 0;
    NSUInteger c = 0;
    count(values, &sum, &c);
    return sum / c;
}
@interface NSUUID (RLMUUIDCompateTests)
- (NSComparisonResult)compare:(NSUUID *)other;
@end
@implementation NSUUID (RLMUUIDCompateTests)
- (NSComparisonResult)compare:(NSUUID *)other {
    return [[self UUIDString] compare:other.UUIDString];
}
@end
@interface RLMDictionary (Tests)
-(void)addObjects:(NSDictionary *)dictionary;
@end
@implementation RLMDictionary (Tests)
-(void)addObjects:(NSDictionary *)dictionary {
    for (id key in dictionary.allKeys) {
        self[key] = dictionary[key];
    }
}
@end
@interface LinkToAllPrimitiveDictionaries : RLMObject
@property (nonatomic) AllPrimitiveDictionaries *link;
@end
@implementation LinkToAllPrimitiveDictionaries
@end

@interface LinkToAllOptionalPrimitiveDictionaries : RLMObject
@property (nonatomic) AllOptionalPrimitiveDictionaries *link;
@end
@implementation LinkToAllOptionalPrimitiveDictionaries
@end

@interface PrimitiveDictionaryPropertyTests : RLMTestCase
@end

@implementation PrimitiveDictionaryPropertyTests {
    AllPrimitiveDictionaries *unmanaged;
    AllPrimitiveDictionaries *managed;
    AllOptionalPrimitiveDictionaries *optUnmanaged;
    AllOptionalPrimitiveDictionaries *optManaged;
    RLMRealm *realm;
    NSArray<RLMDictionary *> *allDictionaries;
}

- (void)setUp {
    unmanaged = [[AllPrimitiveDictionaries alloc] init];
    optUnmanaged = [[AllOptionalPrimitiveDictionaries alloc] init];
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    managed = [AllPrimitiveDictionaries createInRealm:realm withValue:@[]];
    optManaged = [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@[]];
    allDictionaries = @[
        unmanaged.boolObj,
        unmanaged.intObj,
        unmanaged.stringObj,
        optUnmanaged.boolObj,
        optUnmanaged.intObj,
        optUnmanaged.stringObj,
        managed.boolObj,
        managed.intObj,
        managed.stringObj,
        optManaged.boolObj,
        optManaged.intObj,
        optManaged.stringObj,
    ];
}

- (void)tearDown {
    if (realm.inWriteTransaction) {
        [realm cancelWriteTransaction];
    }
}

- (void)addObjects {
    [unmanaged.boolObj addObjects:@{@"0": @NO, @"1": @YES}];
    [unmanaged.intObj addObjects:@{@"0": @2, @"1": @3}];
    [unmanaged.stringObj addObjects:@{@"0": @"a", @"1": @"b"}];
    [optUnmanaged.boolObj addObjects:@{@"0": @NO, @"1": @YES, @"2": NSNull.null}];
    [optUnmanaged.intObj addObjects:@{@"0": @2, @"1": @3, @"2": NSNull.null}];
    [optUnmanaged.stringObj addObjects:@{@"0": @"a", @"1": @"b", @"2": NSNull.null}];
    [managed.boolObj addObjects:@{@"0": @NO, @"1": @YES}];
    [managed.intObj addObjects:@{@"0": @2, @"1": @3}];
    [managed.stringObj addObjects:@{@"0": @"a", @"1": @"b"}];
    [optManaged.boolObj addObjects:@{@"0": @NO, @"1": @YES, @"2": NSNull.null}];
    [optManaged.intObj addObjects:@{@"0": @2, @"1": @3, @"2": NSNull.null}];
    [optManaged.stringObj addObjects:@{@"0": @"a", @"1": @"b", @"2": NSNull.null}];
}

- (void)testCount {
    XCTAssertEqual(unmanaged.intObj.count, 0U);
    unmanaged.intObj[@"testVal"] = @1;
    XCTAssertEqual(unmanaged.intObj.count, 1U);
}

- (void)testType {
    XCTAssertEqual(unmanaged.boolObj.type, RLMPropertyTypeBool);
    XCTAssertEqual(unmanaged.intObj.type, RLMPropertyTypeInt);
    XCTAssertEqual(unmanaged.floatObj.type, RLMPropertyTypeFloat);
    XCTAssertEqual(unmanaged.doubleObj.type, RLMPropertyTypeDouble);
    XCTAssertEqual(unmanaged.stringObj.type, RLMPropertyTypeString);
    XCTAssertEqual(unmanaged.dataObj.type, RLMPropertyTypeData);
    XCTAssertEqual(unmanaged.dateObj.type, RLMPropertyTypeDate);
    XCTAssertEqual(optUnmanaged.boolObj.type, RLMPropertyTypeBool);
    XCTAssertEqual(optUnmanaged.intObj.type, RLMPropertyTypeInt);
    XCTAssertEqual(optUnmanaged.floatObj.type, RLMPropertyTypeFloat);
    XCTAssertEqual(optUnmanaged.doubleObj.type, RLMPropertyTypeDouble);
    XCTAssertEqual(optUnmanaged.stringObj.type, RLMPropertyTypeString);
    XCTAssertEqual(optUnmanaged.dataObj.type, RLMPropertyTypeData);
    XCTAssertEqual(optUnmanaged.dateObj.type, RLMPropertyTypeDate);
}

- (void)testOptional {
    XCTAssertFalse(unmanaged.boolObj.optional);
    XCTAssertFalse(unmanaged.intObj.optional);
    XCTAssertFalse(unmanaged.floatObj.optional);
    XCTAssertFalse(unmanaged.doubleObj.optional);
    XCTAssertFalse(unmanaged.stringObj.optional);
    XCTAssertFalse(unmanaged.dataObj.optional);
    XCTAssertFalse(unmanaged.dateObj.optional);
    XCTAssertTrue(optUnmanaged.boolObj.optional);
    XCTAssertTrue(optUnmanaged.intObj.optional);
    XCTAssertTrue(optUnmanaged.floatObj.optional);
    XCTAssertTrue(optUnmanaged.doubleObj.optional);
    XCTAssertTrue(optUnmanaged.stringObj.optional);
    XCTAssertTrue(optUnmanaged.dataObj.optional);
    XCTAssertTrue(optUnmanaged.dateObj.optional);
}

- (void)testObjectClassName {
    XCTAssertNil(unmanaged.boolObj.objectClassName);
    XCTAssertNil(unmanaged.intObj.objectClassName);
    XCTAssertNil(unmanaged.floatObj.objectClassName);
    XCTAssertNil(unmanaged.doubleObj.objectClassName);
    XCTAssertNil(unmanaged.stringObj.objectClassName);
    XCTAssertNil(unmanaged.dataObj.objectClassName);
    XCTAssertNil(unmanaged.dateObj.objectClassName);
    XCTAssertNil(optUnmanaged.boolObj.objectClassName);
    XCTAssertNil(optUnmanaged.intObj.objectClassName);
    XCTAssertNil(optUnmanaged.floatObj.objectClassName);
    XCTAssertNil(optUnmanaged.doubleObj.objectClassName);
    XCTAssertNil(optUnmanaged.stringObj.objectClassName);
    XCTAssertNil(optUnmanaged.dataObj.objectClassName);
    XCTAssertNil(optUnmanaged.dateObj.objectClassName);
}

- (void)testRealm {
    XCTAssertNil(unmanaged.boolObj.realm);
    XCTAssertNil(unmanaged.intObj.realm);
    XCTAssertNil(unmanaged.floatObj.realm);
    XCTAssertNil(unmanaged.doubleObj.realm);
    XCTAssertNil(unmanaged.stringObj.realm);
    XCTAssertNil(unmanaged.dataObj.realm);
    XCTAssertNil(unmanaged.dateObj.realm);
    XCTAssertNil(optUnmanaged.boolObj.realm);
    XCTAssertNil(optUnmanaged.intObj.realm);
    XCTAssertNil(optUnmanaged.floatObj.realm);
    XCTAssertNil(optUnmanaged.doubleObj.realm);
    XCTAssertNil(optUnmanaged.stringObj.realm);
    XCTAssertNil(optUnmanaged.dataObj.realm);
    XCTAssertNil(optUnmanaged.dateObj.realm);
}

- (void)testInvalidated {
    RLMDictionary *dictionary;
    @autoreleasepool {
        AllPrimitiveDictionaries *obj = [[AllPrimitiveDictionaries alloc] init];
        dictionary = obj.intObj;
        XCTAssertFalse(dictionary.invalidated);
    }
    XCTAssertFalse(dictionary.invalidated);
}

- (void)testDeleteObjectsInRealm {
    RLMAssertThrowsWithReason([realm deleteObjects:unmanaged.boolObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:unmanaged.intObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:unmanaged.stringObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:optUnmanaged.boolObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:optUnmanaged.intObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:optUnmanaged.stringObj], @"Cannot delete objects from RLMDictionary");
    RLMAssertThrowsWithReason([realm deleteObjects:managed.boolObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, bool>: only RLMObjects can be deleted.");
    RLMAssertThrowsWithReason([realm deleteObjects:managed.intObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, int>: only RLMObjects can be deleted.");
    RLMAssertThrowsWithReason([realm deleteObjects:managed.stringObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, string>: only RLMObjects can be deleted.");
    RLMAssertThrowsWithReason([realm deleteObjects:optManaged.boolObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, bool?>: only RLMObjects can be deleted.");
    RLMAssertThrowsWithReason([realm deleteObjects:optManaged.intObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, int?>: only RLMObjects can be deleted.");
    RLMAssertThrowsWithReason([realm deleteObjects:optManaged.stringObj], @"Cannot delete objects from RLMManagedDictionary<RLMString, string?>: only RLMObjects can be deleted.");
}

/**
- (void)testLastObject {
    for (RLMDictionary *dictionary in allDictionaries) {
        XCTAssertNil(dictionary.lastObject);
    }

    [self addObjects];

    XCTAssertEqualObjects(unmanaged.boolObj.lastObject, @YES);
    XCTAssertEqualObjects(unmanaged.intObj.lastObject, @3);
    XCTAssertEqualObjects(unmanaged.stringObj.lastObject, @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj.lastObject, NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj.lastObject, NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj.lastObject, NSNull.null);
    XCTAssertEqualObjects(managed.boolObj.lastObject, @YES);
    XCTAssertEqualObjects(managed.intObj.lastObject, @3);
    XCTAssertEqualObjects(managed.stringObj.lastObject, @"b");
    XCTAssertEqualObjects(optManaged.boolObj.lastObject, NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj.lastObject, NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj.lastObject, NSNull.null);

    for (RLMDictionary *dictionary in allDictionaries) {
        [dictionary removeLastObject];
    }
    XCTAssertEqualObjects(optUnmanaged.boolObj.lastObject, @YES);
    XCTAssertEqualObjects(optUnmanaged.intObj.lastObject, @3);
    XCTAssertEqualObjects(optUnmanaged.stringObj.lastObject, @"b");
    XCTAssertEqualObjects(optManaged.boolObj.lastObject, @YES);
    XCTAssertEqualObjects(optManaged.intObj.lastObject, @3);
    XCTAssertEqualObjects(optManaged.stringObj.lastObject, @"b");
}
*/

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

- (void)testSetObject {
    // Managed non-optional
    XCTAssertNil(managed.boolObj[@"testVal"]);
    XCTAssertNil(managed.intObj[@"testVal"]);
    XCTAssertNil(managed.stringObj[@"testVal"]);
    XCTAssertNoThrow(managed.boolObj[@"testVal"] = @NO);
    XCTAssertNoThrow(managed.intObj[@"testVal"] = @2);
    XCTAssertNoThrow(managed.stringObj[@"testVal"] = @"a");
    XCTAssertEqualObjects(managed.boolObj[@"testVal"], @NO);
    XCTAssertEqualObjects(managed.intObj[@"testVal"], @2);
    XCTAssertEqualObjects(managed.stringObj[@"testVal"], @"a");
    RLMAssertThrowsWithReason(managed.boolObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'.");
    RLMAssertThrowsWithReason(managed.intObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'int'.");
    RLMAssertThrowsWithReason(managed.stringObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'string'.");
    XCTAssertNoThrow(managed.boolObj[@"testVal"] = nil);
    XCTAssertNoThrow(managed.intObj[@"testVal"] = nil);
    XCTAssertNoThrow(managed.stringObj[@"testVal"] = nil);
    XCTAssertNil(managed.boolObj[@"testVal"]);
    XCTAssertNil(managed.intObj[@"testVal"]);
    XCTAssertNil(managed.stringObj[@"testVal"]);

    // Managed optional
    XCTAssertNil(optManaged.boolObj[@"testVal"]);
    XCTAssertNil(optManaged.intObj[@"testVal"]);
    XCTAssertNil(optManaged.stringObj[@"testVal"]);
    XCTAssertNoThrow(optManaged.boolObj[@"testVal"] = @NO);
    XCTAssertNoThrow(optManaged.intObj[@"testVal"] = @2);
    XCTAssertNoThrow(optManaged.stringObj[@"testVal"] = @"a");
    XCTAssertEqualObjects(optManaged.boolObj[@"testVal"], @NO);
    XCTAssertEqualObjects(optManaged.intObj[@"testVal"], @2);
    XCTAssertEqualObjects(optManaged.stringObj[@"testVal"], @"a");
    XCTAssertNoThrow(optManaged.boolObj[@"testVal"] = NSNull.null);
    XCTAssertNoThrow(optManaged.intObj[@"testVal"] = NSNull.null);
    XCTAssertNoThrow(optManaged.stringObj[@"testVal"] = NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[@"testVal"], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[@"testVal"], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[@"testVal"], NSNull.null);
    XCTAssertNoThrow(optManaged.boolObj[@"testVal"] = nil);
    XCTAssertNoThrow(optManaged.intObj[@"testVal"] = nil);
    XCTAssertNoThrow(optManaged.stringObj[@"testVal"] = nil);
    XCTAssertNil(optManaged.boolObj[@"testVal"]);
    XCTAssertNil(optManaged.intObj[@"testVal"]);
    XCTAssertNil(optManaged.stringObj[@"testVal"]);

    // Unmanaged non-optional
    XCTAssertNil(unmanaged.boolObj[@"testVal"]);
    XCTAssertNil(unmanaged.intObj[@"testVal"]);
    XCTAssertNil(unmanaged.stringObj[@"testVal"]);
    XCTAssertNoThrow(unmanaged.boolObj[@"testVal"] = @NO);
    XCTAssertNoThrow(unmanaged.intObj[@"testVal"] = @2);
    XCTAssertNoThrow(unmanaged.stringObj[@"testVal"] = @"a");
    XCTAssertEqual(unmanaged.boolObj[@"testVal"], @NO);
    XCTAssertEqual(unmanaged.intObj[@"testVal"], @2);
    XCTAssertEqual(unmanaged.stringObj[@"testVal"], @"a");
    RLMAssertThrowsWithReason(unmanaged.boolObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'.");
    RLMAssertThrowsWithReason(unmanaged.intObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'int'.");
    RLMAssertThrowsWithReason(unmanaged.stringObj[@"testVal"] = NSNull.null, @"Invalid value '<null>' of type 'NSNull' for expected type 'string'.");
    XCTAssertNoThrow(unmanaged.boolObj[@"testVal"] = nil);
    XCTAssertNoThrow(unmanaged.intObj[@"testVal"] = nil);
    XCTAssertNoThrow(unmanaged.stringObj[@"testVal"] = nil);
    XCTAssertNil(unmanaged.boolObj[@"testVal"]);
    XCTAssertNil(unmanaged.intObj[@"testVal"]);
    XCTAssertNil(unmanaged.stringObj[@"testVal"]);

    // Unmanaged optional
    XCTAssertNil(optUnmanaged.boolObj[@"testVal"]);
    XCTAssertNil(optUnmanaged.intObj[@"testVal"]);
    XCTAssertNil(optUnmanaged.stringObj[@"testVal"]);
    XCTAssertNoThrow(optUnmanaged.boolObj[@"testVal"] = @NO);
    XCTAssertNoThrow(optUnmanaged.intObj[@"testVal"] = @2);
    XCTAssertNoThrow(optUnmanaged.stringObj[@"testVal"] = @"a");
    XCTAssertEqual(optUnmanaged.boolObj[@"testVal"], @NO);
    XCTAssertEqual(optUnmanaged.intObj[@"testVal"], @2);
    XCTAssertEqual(optUnmanaged.stringObj[@"testVal"], @"a");
    XCTAssertNoThrow(optUnmanaged.boolObj[@"testVal"] = NSNull.null);
    XCTAssertNoThrow(optUnmanaged.intObj[@"testVal"] = NSNull.null);
    XCTAssertNoThrow(optUnmanaged.stringObj[@"testVal"] = NSNull.null);
    XCTAssertEqual(optUnmanaged.boolObj[@"testVal"], NSNull.null);
    XCTAssertEqual(optUnmanaged.intObj[@"testVal"], NSNull.null);
    XCTAssertEqual(optUnmanaged.stringObj[@"testVal"], NSNull.null);
    XCTAssertNoThrow(optUnmanaged.boolObj[@"testVal"] = nil);
    XCTAssertNoThrow(optUnmanaged.intObj[@"testVal"] = nil);
    XCTAssertNoThrow(optUnmanaged.stringObj[@"testVal"] = nil);
    XCTAssertNil(optUnmanaged.boolObj[@"testVal"]);
    XCTAssertNil(optUnmanaged.intObj[@"testVal"]);
    XCTAssertNil(optUnmanaged.stringObj[@"testVal"]);

    // Fail with nil key
    RLMAssertThrowsWithReason([unmanaged.boolObj setObject:@NO forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([unmanaged.intObj setObject:@2 forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([unmanaged.stringObj setObject:@"a" forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj setObject:@NO forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optUnmanaged.intObj setObject:@2 forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj setObject:@"a" forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([managed.boolObj setObject:@NO forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([managed.intObj setObject:@2 forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([managed.stringObj setObject:@"a" forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optManaged.boolObj setObject:@NO forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optManaged.intObj setObject:@2 forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    RLMAssertThrowsWithReason([optManaged.stringObj setObject:@"a" forKey:nil],
                              @"Invalid nil key for dictionary expecting key of type 'string'.");
    // Fail on set nil for non-optional
    RLMAssertThrowsWithReason([unmanaged.boolObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([managed.boolObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj setObject:NSNull.null forKey: @"testVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    // f
    RLMAssertThrowsWithReason([unmanaged.boolObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj setObject:@2 forKey: @"wrongVal"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optUnmanaged.intObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj setObject:@2 forKey: @"wrongVal"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([managed.boolObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj setObject:@2 forKey: @"wrongVal"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optManaged.boolObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optManaged.intObj setObject:@"a" forKey: @"wrongVal"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optManaged.stringObj setObject:@2 forKey: @"wrongVal"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([unmanaged.boolObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([managed.boolObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj setObject:NSNull.null forKey: @"nullVal"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");

    unmanaged.boolObj[@"val"] = @NO;
    unmanaged.intObj[@"val"] = @2;
    unmanaged.stringObj[@"val"] = @"a";
    optUnmanaged.boolObj[@"val"] = @NO;
    optUnmanaged.intObj[@"val"] = @2;
    optUnmanaged.stringObj[@"val"] = @"a";
    managed.boolObj[@"val"] = @NO;
    managed.intObj[@"val"] = @2;
    managed.stringObj[@"val"] = @"a";
    optManaged.boolObj[@"val"] = @NO;
    optManaged.intObj[@"val"] = @2;
    optManaged.stringObj[@"val"] = @"a";
    XCTAssertEqualObjects(unmanaged.boolObj[@"val"], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[@"val"], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[@"val"], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"val"], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"val"], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"val"], @"a");
    XCTAssertEqualObjects(managed.boolObj[@"val"], @NO);
    XCTAssertEqualObjects(managed.intObj[@"val"], @2);
    XCTAssertEqualObjects(managed.stringObj[@"val"], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[@"val"], @NO);
    XCTAssertEqualObjects(optManaged.intObj[@"val"], @2);
    XCTAssertEqualObjects(optManaged.stringObj[@"val"], @"a");

    optUnmanaged.boolObj[@"val"] = NSNull.null;
    optUnmanaged.intObj[@"val"] = NSNull.null;
    optUnmanaged.stringObj[@"val"] = NSNull.null;
    optManaged.boolObj[@"val"] = NSNull.null;
    optManaged.intObj[@"val"] = NSNull.null;
    optManaged.stringObj[@"val"] = NSNull.null;
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"val"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"val"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"val"], NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[@"val"], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[@"val"], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[@"val"], NSNull.null);
}
#pragma clang diagnostic pop

- (void)testAddObjects {
    RLMAssertThrowsWithReason([unmanaged.boolObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj addObjects:@{@"wrongVal": @2}],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optUnmanaged.intObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj addObjects:@{@"wrongVal": @2}],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([managed.boolObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj addObjects:@{@"wrongVal": @2}],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optManaged.boolObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optManaged.intObj addObjects:@{@"wrongVal": @"a"}],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optManaged.stringObj addObjects:@{@"wrongVal": @2}],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([unmanaged.boolObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([managed.boolObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj addObjects:@{@"nullVal": NSNull.null}],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");

    [self addObjects];
    XCTAssertEqualObjects(unmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(managed.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(managed.intObj[@"0"], @2);
    XCTAssertEqualObjects(managed.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optManaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optManaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(unmanaged.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(unmanaged.intObj[@"1"], @3);
    XCTAssertEqualObjects(unmanaged.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"1"], @3);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(managed.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(managed.intObj[@"1"], @3);
    XCTAssertEqualObjects(managed.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(optManaged.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(optManaged.intObj[@"1"], @3);
    XCTAssertEqualObjects(optManaged.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[@"2"], NSNull.null);
}
/**
- (void)testInsertObject {
    RLMAssertThrowsWithReason([unmanaged.boolObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj insertObject:@2 atIndex:0],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optUnmanaged.intObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj insertObject:@2 atIndex:0],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([managed.boolObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj insertObject:@2 atIndex:0],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optManaged.boolObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optManaged.intObj insertObject:@"a" atIndex:0],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optManaged.stringObj insertObject:@2 atIndex:0],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([unmanaged.boolObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([managed.boolObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj insertObject:NSNull.null atIndex:0],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([unmanaged.boolObj insertObject:@NO atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([unmanaged.intObj insertObject:@2 atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([unmanaged.stringObj insertObject:@"a" atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj insertObject:@NO atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optUnmanaged.intObj insertObject:@2 atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj insertObject:@"a" atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([managed.boolObj insertObject:@NO atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([managed.intObj insertObject:@2 atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([managed.stringObj insertObject:@"a" atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optManaged.boolObj insertObject:@NO atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optManaged.intObj insertObject:@2 atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");
    RLMAssertThrowsWithReason([optManaged.stringObj insertObject:@"a" atIndex:1],
                              @"Index 1 is out of bounds (must be less than 1).");

    [unmanaged.boolObj insertObject:@NO atIndex:0];
    [unmanaged.intObj insertObject:@2 atIndex:0];
    [unmanaged.stringObj insertObject:@"a" atIndex:0];
    [optUnmanaged.boolObj insertObject:@NO atIndex:0];
    [optUnmanaged.intObj insertObject:@2 atIndex:0];
    [optUnmanaged.stringObj insertObject:@"a" atIndex:0];
    [managed.boolObj insertObject:@NO atIndex:0];
    [managed.intObj insertObject:@2 atIndex:0];
    [managed.stringObj insertObject:@"a" atIndex:0];
    [optManaged.boolObj insertObject:@NO atIndex:0];
    [optManaged.intObj insertObject:@2 atIndex:0];
    [optManaged.stringObj insertObject:@"a" atIndex:0];
    XCTAssertEqualObjects(unmanaged.boolObj[0], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[0], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[0], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[0], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[0], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[0], @"a");
    XCTAssertEqualObjects(managed.boolObj[0], @NO);
    XCTAssertEqualObjects(managed.intObj[0], @2);
    XCTAssertEqualObjects(managed.stringObj[0], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[0], @NO);
    XCTAssertEqualObjects(optManaged.intObj[0], @2);
    XCTAssertEqualObjects(optManaged.stringObj[0], @"a");

    [unmanaged.boolObj insertObject:@YES atIndex:0];
    [unmanaged.intObj insertObject:@3 atIndex:0];
    [unmanaged.stringObj insertObject:@"b" atIndex:0];
    [optUnmanaged.boolObj insertObject:@YES atIndex:0];
    [optUnmanaged.intObj insertObject:@3 atIndex:0];
    [optUnmanaged.stringObj insertObject:@"b" atIndex:0];
    [managed.boolObj insertObject:@YES atIndex:0];
    [managed.intObj insertObject:@3 atIndex:0];
    [managed.stringObj insertObject:@"b" atIndex:0];
    [optManaged.boolObj insertObject:@YES atIndex:0];
    [optManaged.intObj insertObject:@3 atIndex:0];
    [optManaged.stringObj insertObject:@"b" atIndex:0];
    XCTAssertEqualObjects(unmanaged.boolObj[0], @YES);
    XCTAssertEqualObjects(unmanaged.intObj[0], @3);
    XCTAssertEqualObjects(unmanaged.stringObj[0], @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj[0], @YES);
    XCTAssertEqualObjects(optUnmanaged.intObj[0], @3);
    XCTAssertEqualObjects(optUnmanaged.stringObj[0], @"b");
    XCTAssertEqualObjects(managed.boolObj[0], @YES);
    XCTAssertEqualObjects(managed.intObj[0], @3);
    XCTAssertEqualObjects(managed.stringObj[0], @"b");
    XCTAssertEqualObjects(optManaged.boolObj[0], @YES);
    XCTAssertEqualObjects(optManaged.intObj[0], @3);
    XCTAssertEqualObjects(optManaged.stringObj[0], @"b");
    XCTAssertEqualObjects(unmanaged.boolObj[1], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[1], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[1], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[1], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[1], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[1], @"a");
    XCTAssertEqualObjects(managed.boolObj[1], @NO);
    XCTAssertEqualObjects(managed.intObj[1], @2);
    XCTAssertEqualObjects(managed.stringObj[1], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[1], @NO);
    XCTAssertEqualObjects(optManaged.intObj[1], @2);
    XCTAssertEqualObjects(optManaged.stringObj[1], @"a");

    [optUnmanaged.boolObj insertObject:NSNull.null atIndex:1];
    [optUnmanaged.intObj insertObject:NSNull.null atIndex:1];
    [optUnmanaged.stringObj insertObject:NSNull.null atIndex:1];
    [optManaged.boolObj insertObject:NSNull.null atIndex:1];
    [optManaged.intObj insertObject:NSNull.null atIndex:1];
    [optManaged.stringObj insertObject:NSNull.null atIndex:1];
    XCTAssertEqualObjects(optUnmanaged.boolObj[0], @YES);
    XCTAssertEqualObjects(optUnmanaged.intObj[0], @3);
    XCTAssertEqualObjects(optUnmanaged.stringObj[0], @"b");
    XCTAssertEqualObjects(optManaged.boolObj[0], @YES);
    XCTAssertEqualObjects(optManaged.intObj[0], @3);
    XCTAssertEqualObjects(optManaged.stringObj[0], @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj[1], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj[1], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj[1], NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[1], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[1], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[1], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.boolObj[2], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[2], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[2], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[2], @NO);
    XCTAssertEqualObjects(optManaged.intObj[2], @2);
    XCTAssertEqualObjects(optManaged.stringObj[2], @"a");
}
 */
- (void)testRemoveObject {
    [self addObjects];
    XCTAssertEqual(unmanaged.boolObj.count, 2U);
    XCTAssertEqual(unmanaged.intObj.count, 2U);
    XCTAssertEqual(unmanaged.stringObj.count, 2U);
    XCTAssertEqual(managed.boolObj.count, 2U);
    XCTAssertEqual(managed.intObj.count, 2U);
    XCTAssertEqual(managed.stringObj.count, 2U);
    XCTAssertEqual(optUnmanaged.boolObj.count, 3U);
    XCTAssertEqual(optUnmanaged.intObj.count, 3U);
    XCTAssertEqual(optUnmanaged.stringObj.count, 3U);
    XCTAssertEqual(optManaged.boolObj.count, 3U);
    XCTAssertEqual(optManaged.intObj.count, 3U);
    XCTAssertEqual(optManaged.stringObj.count, 3U);

    XCTAssertEqualObjects(unmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(managed.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(managed.intObj[@"0"], @2);
    XCTAssertEqualObjects(managed.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optManaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optManaged.stringObj[@"0"], @"a");

    for (RLMDictionary *dictionary in allDictionaries) {
        [dictionary removeObjectForKey:@"0"];
    }
    XCTAssertEqual(unmanaged.boolObj.count, 1U);
    XCTAssertEqual(unmanaged.intObj.count, 1U);
    XCTAssertEqual(unmanaged.stringObj.count, 1U);
    XCTAssertEqual(managed.boolObj.count, 1U);
    XCTAssertEqual(managed.intObj.count, 1U);
    XCTAssertEqual(managed.stringObj.count, 1U);
    XCTAssertEqual(optUnmanaged.boolObj.count, 2U);
    XCTAssertEqual(optUnmanaged.intObj.count, 2U);
    XCTAssertEqual(optUnmanaged.stringObj.count, 2U);
    XCTAssertEqual(optManaged.boolObj.count, 2U);
    XCTAssertEqual(optManaged.intObj.count, 2U);
    XCTAssertEqual(optManaged.stringObj.count, 2U);

    XCTAssertNil(unmanaged.boolObj[@"0"]);
    XCTAssertNil(unmanaged.intObj[@"0"]);
    XCTAssertNil(unmanaged.stringObj[@"0"]);
    XCTAssertNil(optUnmanaged.boolObj[@"0"]);
    XCTAssertNil(optUnmanaged.intObj[@"0"]);
    XCTAssertNil(optUnmanaged.stringObj[@"0"]);
    XCTAssertNil(managed.boolObj[@"0"]);
    XCTAssertNil(managed.intObj[@"0"]);
    XCTAssertNil(managed.stringObj[@"0"]);
    XCTAssertNil(optManaged.boolObj[@"0"]);
    XCTAssertNil(optManaged.intObj[@"0"]);
    XCTAssertNil(optManaged.stringObj[@"0"]);
}

- (void)testRemoveObjects {
    [self addObjects];
    XCTAssertEqual(unmanaged.boolObj.count, 2U);
    XCTAssertEqual(unmanaged.intObj.count, 2U);
    XCTAssertEqual(unmanaged.stringObj.count, 2U);
    XCTAssertEqual(managed.boolObj.count, 2U);
    XCTAssertEqual(managed.intObj.count, 2U);
    XCTAssertEqual(managed.stringObj.count, 2U);
    XCTAssertEqual(optUnmanaged.boolObj.count, 3U);
    XCTAssertEqual(optUnmanaged.intObj.count, 3U);
    XCTAssertEqual(optUnmanaged.stringObj.count, 3U);
    XCTAssertEqual(optManaged.boolObj.count, 3U);
    XCTAssertEqual(optManaged.intObj.count, 3U);
    XCTAssertEqual(optManaged.stringObj.count, 3U);

    XCTAssertEqualObjects(unmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(managed.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(managed.intObj[@"0"], @2);
    XCTAssertEqualObjects(managed.stringObj[@"0"], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[@"0"], @NO);
    XCTAssertEqualObjects(optManaged.intObj[@"0"], @2);
    XCTAssertEqualObjects(optManaged.stringObj[@"0"], @"a");

    for (RLMDictionary *dictionary in allDictionaries) {
        [dictionary removeObjectsForKeys:@[@"0"]];
    }
    XCTAssertEqual(unmanaged.boolObj.count, 1U);
    XCTAssertEqual(unmanaged.intObj.count, 1U);
    XCTAssertEqual(unmanaged.stringObj.count, 1U);
    XCTAssertEqual(managed.boolObj.count, 1U);
    XCTAssertEqual(managed.intObj.count, 1U);
    XCTAssertEqual(managed.stringObj.count, 1U);
    XCTAssertEqual(optUnmanaged.boolObj.count, 2U);
    XCTAssertEqual(optUnmanaged.intObj.count, 2U);
    XCTAssertEqual(optUnmanaged.stringObj.count, 2U);
    XCTAssertEqual(optManaged.boolObj.count, 2U);
    XCTAssertEqual(optManaged.intObj.count, 2U);
    XCTAssertEqual(optManaged.stringObj.count, 2U);

    XCTAssertNil(unmanaged.boolObj[@"0"]);
    XCTAssertNil(unmanaged.intObj[@"0"]);
    XCTAssertNil(unmanaged.stringObj[@"0"]);
    XCTAssertNil(optUnmanaged.boolObj[@"0"]);
    XCTAssertNil(optUnmanaged.intObj[@"0"]);
    XCTAssertNil(optUnmanaged.stringObj[@"0"]);
    XCTAssertNil(managed.boolObj[@"0"]);
    XCTAssertNil(managed.intObj[@"0"]);
    XCTAssertNil(managed.stringObj[@"0"]);
    XCTAssertNil(optManaged.boolObj[@"0"]);
    XCTAssertNil(optManaged.intObj[@"0"]);
    XCTAssertNil(optManaged.stringObj[@"0"]);
}

- (void)testUpdateObjects {
    [self addObjects];
    XCTAssertEqual(unmanaged.boolObj.count, 2U);
    XCTAssertEqual(unmanaged.intObj.count, 2U);
    XCTAssertEqual(unmanaged.stringObj.count, 2U);
    XCTAssertEqual(managed.boolObj.count, 2U);
    XCTAssertEqual(managed.intObj.count, 2U);
    XCTAssertEqual(managed.stringObj.count, 2U);
    XCTAssertEqual(optUnmanaged.boolObj.count, 3U);
    XCTAssertEqual(optUnmanaged.intObj.count, 3U);
    XCTAssertEqual(optUnmanaged.stringObj.count, 3U);
    XCTAssertEqual(optManaged.boolObj.count, 3U);
    XCTAssertEqual(optManaged.intObj.count, 3U);
    XCTAssertEqual(optManaged.stringObj.count, 3U);

    XCTAssertEqualObjects(unmanaged.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(unmanaged.intObj[@"1"], @3);
    XCTAssertEqualObjects(unmanaged.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(managed.boolObj[@"1"], @YES);
    XCTAssertEqualObjects(managed.intObj[@"1"], @3);
    XCTAssertEqualObjects(managed.stringObj[@"1"], @"b");
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[@"2"], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[@"2"], NSNull.null);

    unmanaged.boolObj[@"1"] = unmanaged.boolObj[@"0"];
    unmanaged.intObj[@"1"] = unmanaged.intObj[@"0"];
    unmanaged.stringObj[@"1"] = unmanaged.stringObj[@"0"];
    managed.boolObj[@"1"] = managed.boolObj[@"0"];
    managed.intObj[@"1"] = managed.intObj[@"0"];
    managed.stringObj[@"1"] = managed.stringObj[@"0"];
    optUnmanaged.boolObj[@"2"] = optUnmanaged.boolObj[@"1"];
    optUnmanaged.intObj[@"2"] = optUnmanaged.intObj[@"1"];
    optUnmanaged.stringObj[@"2"] = optUnmanaged.stringObj[@"1"];
    optManaged.boolObj[@"2"] = optManaged.boolObj[@"1"];
    optManaged.intObj[@"2"] = optManaged.intObj[@"1"];
    optManaged.stringObj[@"2"] = optManaged.stringObj[@"1"];

    XCTAssertNotEqualObjects(unmanaged.boolObj[@"1"], @YES);
    XCTAssertNotEqualObjects(unmanaged.intObj[@"1"], @3);
    XCTAssertNotEqualObjects(unmanaged.stringObj[@"1"], @"b");
    XCTAssertNotEqualObjects(managed.boolObj[@"1"], @YES);
    XCTAssertNotEqualObjects(managed.intObj[@"1"], @3);
    XCTAssertNotEqualObjects(managed.stringObj[@"1"], @"b");
    XCTAssertNotEqualObjects(optUnmanaged.boolObj[@"2"], NSNull.null);
    XCTAssertNotEqualObjects(optUnmanaged.intObj[@"2"], NSNull.null);
    XCTAssertNotEqualObjects(optUnmanaged.stringObj[@"2"], NSNull.null);
    XCTAssertNotEqualObjects(optManaged.boolObj[@"2"], NSNull.null);
    XCTAssertNotEqualObjects(optManaged.intObj[@"2"], NSNull.null);
    XCTAssertNotEqualObjects(optManaged.stringObj[@"2"], NSNull.null);
}

- (void)testIndexOfObjectSorted {
    [managed.boolObj addObjects:@{@"2": @NO, @"3": @YES, @"4": @NO, @"5": @YES}];
    [managed.intObj addObjects:@{@"2": @2, @"3": @3, @"4": @2, @"5": @3}];
    [managed.stringObj addObjects:@{@"2": @"a", @"3": @"b", @"4": @"a", @"5": @"b"}];
    [optManaged.boolObj addObjects:@{@"2": @NO, @"3": @YES, @"4": NSNull.null, @"5": @YES, @"6": @NO}];
    [optManaged.intObj addObjects:@{@"2": @2, @"3": @3, @"4": NSNull.null, @"5": @3, @"6": @2}];
    [optManaged.stringObj addObjects:@{@"2": @"a", @"3": @"b", @"4": NSNull.null, @"5": @"b", @"6": @"a"}];

    XCTAssertEqual(0U, [[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(0U, [[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(0U, [[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(2U, [[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);
    XCTAssertEqual(2U, [[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);
    XCTAssertEqual(2U, [[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);

    XCTAssertEqual(0U, [[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(0U, [[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(0U, [[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"1"]);
    XCTAssertEqual(2U, [[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);
    XCTAssertEqual(2U, [[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);
    XCTAssertEqual(2U, [[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:@"0"]);
    XCTAssertEqual(4U, [[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:NSNull.null]);
    XCTAssertEqual(4U, [[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:NSNull.null]);
    XCTAssertEqual(4U, [[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] indexOfObject:NSNull.null]);
}

- (void)testIndexOfObjectDistinct {
    [managed.boolObj addObjects:@{@"2": @NO, @"3": @NO, @"4": @YES}];
    [managed.intObj addObjects:@{@"2": @2, @"3": @2, @"4": @3}];
    [managed.stringObj addObjects:@{@"2": @"a", @"3": @"a", @"4": @"b"}];
    [optManaged.boolObj addObjects:@{@"2": @NO, @"3": @NO, @"4": NSNull.null, @"5": @YES, @"6": @NO}];
    [optManaged.intObj addObjects:@{@"2": @2, @"3": @2, @"4": NSNull.null, @"5": @3, @"6": @2}];
    [optManaged.stringObj addObjects:@{@"2": @"a", @"3": @"a", @"4": NSNull.null, @"5": @"b", @"6": @"a"}];

    XCTAssertEqual(0U, [[managed.boolObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@NO]);
    XCTAssertEqual(0U, [[managed.intObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@2]);
    XCTAssertEqual(0U, [[managed.stringObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@"a"]);
    XCTAssertEqual(1U, [[managed.boolObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@YES]);
    XCTAssertEqual(1U, [[managed.intObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@3]);
    XCTAssertEqual(1U, [[managed.stringObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@"b"]);

    XCTAssertEqual(0U, [[optManaged.boolObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@NO]);
    XCTAssertEqual(0U, [[optManaged.intObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@2]);
    XCTAssertEqual(0U, [[optManaged.stringObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@"a"]);
    XCTAssertEqual(2U, [[optManaged.boolObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@YES]);
    XCTAssertEqual(2U, [[optManaged.intObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@3]);
    XCTAssertEqual(2U, [[optManaged.stringObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:@"b"]);
    XCTAssertEqual(1U, [[optManaged.boolObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:NSNull.null]);
    XCTAssertEqual(1U, [[optManaged.intObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:NSNull.null]);
    XCTAssertEqual(1U, [[optManaged.stringObj distinctResultsUsingKeyPaths:@[@"self"]] indexOfObject:NSNull.null]);
}

- (void)testIndexOfObjectWhere {
    RLMAssertThrowsWithReason([managed.boolObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([managed.intObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([managed.stringObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([optManaged.boolObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([optManaged.intObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([optManaged.stringObj indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWhere:@"TRUEPREDICATE"], @"implemented");

    XCTAssertEqual(NSNotFound, [unmanaged.boolObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [unmanaged.intObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [unmanaged.stringObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.boolObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.intObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.stringObj indexOfObjectWhere:@"TRUEPREDICATE"]);

    [self addObjects];

    XCTAssertEqual(0U, [unmanaged.boolObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(0U, [unmanaged.intObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(0U, [unmanaged.stringObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(0U, [optUnmanaged.boolObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(0U, [optUnmanaged.intObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(0U, [optUnmanaged.stringObj indexOfObjectWhere:@"TRUEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [unmanaged.boolObj indexOfObjectWhere:@"FALSEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [unmanaged.intObj indexOfObjectWhere:@"FALSEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [unmanaged.stringObj indexOfObjectWhere:@"FALSEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.boolObj indexOfObjectWhere:@"FALSEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.intObj indexOfObjectWhere:@"FALSEPREDICATE"]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.stringObj indexOfObjectWhere:@"FALSEPREDICATE"]);
}

- (void)testIndexOfObjectWithPredicate {
    RLMAssertThrowsWithReason([managed.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([managed.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([managed.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([optManaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([optManaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([optManaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");

    XCTAssertEqual(NSNotFound, [unmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [unmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [unmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);

    [self addObjects];

    XCTAssertEqual(0U, [unmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(0U, [unmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(0U, [unmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(0U, [optUnmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(0U, [optUnmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(0U, [optUnmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]);
    XCTAssertEqual(NSNotFound, [unmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
    XCTAssertEqual(NSNotFound, [unmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
    XCTAssertEqual(NSNotFound, [unmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.boolObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.intObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
    XCTAssertEqual(NSNotFound, [optUnmanaged.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]]);
}

- (void)testSort {
    RLMAssertThrowsWithReason([unmanaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.boolObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.intObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.stringObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.intObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj sortedResultsUsingDescriptors:@[]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([managed.boolObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");
    RLMAssertThrowsWithReason([managed.intObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");
    RLMAssertThrowsWithReason([managed.stringObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");
    RLMAssertThrowsWithReason([optManaged.boolObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");
    RLMAssertThrowsWithReason([optManaged.intObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");
    RLMAssertThrowsWithReason([optManaged.stringObj sortedResultsUsingKeyPath:@"not self" ascending:NO],
                              @"can only be sorted on 'self'");

    [managed.boolObj addObjects:@{@"2": @NO, @"3": @YES, @"4": @NO}];
    [managed.intObj addObjects:@{@"2": @2, @"3": @3, @"4": @2}];
    [managed.stringObj addObjects:@{@"2": @"a", @"3": @"b", @"4": @"a"}];
    [optManaged.boolObj addObjects:@{@"2": @NO, @"3": @YES, @"4": NSNull.null, @"5": @YES, @"6": @NO}];
    [optManaged.intObj addObjects:@{@"2": @2, @"3": @3, @"4": NSNull.null, @"5": @3, @"6": @2}];
    [optManaged.stringObj addObjects:@{@"2": @"a", @"3": @"b", @"4": NSNull.null, @"5": @"b", @"6": @"a"}];

    XCTAssertEqualObjects([[managed.boolObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@NO, @YES, @NO]));
    XCTAssertEqualObjects([[managed.intObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@2, @3, @2]));
    XCTAssertEqualObjects([[managed.stringObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@"a", @"b", @"a"]));
    XCTAssertEqualObjects([[optManaged.boolObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@NO, @YES, NSNull.null, @YES, @NO]));
    XCTAssertEqualObjects([[optManaged.intObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@2, @3, NSNull.null, @3, @2]));
    XCTAssertEqualObjects([[optManaged.stringObj sortedResultsUsingDescriptors:@[]] valueForKey:@"self"],
                          (@[@"a", @"b", NSNull.null, @"b", @"a"]));

    XCTAssertEqualObjects([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@YES, @NO, @NO]));
    XCTAssertEqualObjects([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@3, @2, @2]));
    XCTAssertEqualObjects([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@"b", @"a", @"a"]));
    XCTAssertEqualObjects([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@YES, @YES, @NO, @NO, NSNull.null]));
    XCTAssertEqualObjects([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@3, @3, @2, @2, NSNull.null]));
    XCTAssertEqualObjects([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO] valueForKey:@"self"],
                          (@[@"b", @"b", @"a", @"a", NSNull.null]));

    XCTAssertEqualObjects([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[@NO, @NO, @YES]));
    XCTAssertEqualObjects([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[@2, @2, @3]));
    XCTAssertEqualObjects([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[@"a", @"a", @"b"]));
    XCTAssertEqualObjects([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[NSNull.null, @NO, @NO, @YES, @YES]));
    XCTAssertEqualObjects([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[NSNull.null, @2, @2, @3, @3]));
    XCTAssertEqualObjects([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:YES] valueForKey:@"self"],
                          (@[NSNull.null, @"a", @"a", @"b", @"b"]));
}

- (void)testFilter {
    RLMAssertThrowsWithReason([unmanaged.boolObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.intObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.stringObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.intObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj objectsWhere:@"TRUEPREDICATE"],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.boolObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.intObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.stringObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.intObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");

    RLMAssertThrowsWithReason([managed.boolObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([managed.intObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([managed.stringObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.boolObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.intObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.stringObj objectsWhere:@"TRUEPREDICATE"],
                              @"implemented");
    RLMAssertThrowsWithReason([managed.boolObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");
    RLMAssertThrowsWithReason([managed.intObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");
    RLMAssertThrowsWithReason([managed.stringObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.boolObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.intObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");
    RLMAssertThrowsWithReason([optManaged.stringObj objectsWithPredicate:[NSPredicate predicateWithValue:YES]],
                              @"implemented");

    RLMAssertThrowsWithReason([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWhere:@"TRUEPREDICATE"], @"implemented");
    RLMAssertThrowsWithReason([[managed.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[managed.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[managed.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.boolObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.intObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
    RLMAssertThrowsWithReason([[optManaged.stringObj sortedResultsUsingKeyPath:@"self" ascending:NO]
                               objectsWithPredicate:[NSPredicate predicateWithValue:YES]], @"implemented");
}

- (void)testNotifications {
    RLMAssertThrowsWithReason([unmanaged.boolObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.intObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([unmanaged.stringObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.intObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj addNotificationBlock:^(__unused id a, __unused id c, __unused id e) { }],
                              @"This method may only be called on RLMDictionary instances retrieved from an RLMRealm");
}

- (void)testMin {
    RLMAssertThrowsWithReason([unmanaged.boolObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for bool array");
    RLMAssertThrowsWithReason([unmanaged.stringObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for string array");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for bool? array");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for string? array");
    RLMAssertThrowsWithReason([managed.boolObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for bool array 'AllPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([managed.stringObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for string array 'AllPrimitiveDictionaries.stringObj'");
    RLMAssertThrowsWithReason([optManaged.boolObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for bool? array 'AllOptionalPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([optManaged.stringObj minOfProperty:@"self"],
                              @"minOfProperty: is not supported for string? array 'AllOptionalPrimitiveDictionaries.stringObj'");

    XCTAssertNil([unmanaged.intObj minOfProperty:@"self"]);
    XCTAssertNil([optUnmanaged.intObj minOfProperty:@"self"]);
    XCTAssertNil([managed.intObj minOfProperty:@"self"]);
    XCTAssertNil([optManaged.intObj minOfProperty:@"self"]);

    [self addObjects];

    XCTAssertEqualObjects([unmanaged.intObj minOfProperty:@"self"], @2);
    XCTAssertEqualObjects([optUnmanaged.intObj minOfProperty:@"self"], @2);
    XCTAssertEqualObjects([managed.intObj minOfProperty:@"self"], @2);
    XCTAssertEqualObjects([optManaged.intObj minOfProperty:@"self"], @2);
}

- (void)testMax {
    RLMAssertThrowsWithReason([unmanaged.boolObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for bool array");
    RLMAssertThrowsWithReason([unmanaged.stringObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for string array");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for bool? array");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for string? array");
    RLMAssertThrowsWithReason([managed.boolObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for bool array 'AllPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([managed.stringObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for string array 'AllPrimitiveDictionaries.stringObj'");
    RLMAssertThrowsWithReason([optManaged.boolObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for bool? array 'AllOptionalPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([optManaged.stringObj maxOfProperty:@"self"],
                              @"maxOfProperty: is not supported for string? array 'AllOptionalPrimitiveDictionaries.stringObj'");

    XCTAssertNil([unmanaged.intObj maxOfProperty:@"self"]);
    XCTAssertNil([optUnmanaged.intObj maxOfProperty:@"self"]);
    XCTAssertNil([managed.intObj maxOfProperty:@"self"]);
    XCTAssertNil([optManaged.intObj maxOfProperty:@"self"]);

    [self addObjects];

    XCTAssertEqualObjects([unmanaged.intObj maxOfProperty:@"self"], @3);
    XCTAssertEqualObjects([optUnmanaged.intObj maxOfProperty:@"self"], @3);
    XCTAssertEqualObjects([managed.intObj maxOfProperty:@"self"], @3);
    XCTAssertEqualObjects([optManaged.intObj maxOfProperty:@"self"], @3);
}

- (void)testSum {
    RLMAssertThrowsWithReason([unmanaged.boolObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for bool array");
    RLMAssertThrowsWithReason([unmanaged.stringObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for string array");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for bool? array");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for string? array");
    RLMAssertThrowsWithReason([managed.boolObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for bool array 'AllPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([managed.stringObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for string array 'AllPrimitiveDictionaries.stringObj'");
    RLMAssertThrowsWithReason([optManaged.boolObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for bool? array 'AllOptionalPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([optManaged.stringObj sumOfProperty:@"self"],
                              @"sumOfProperty: is not supported for string? array 'AllOptionalPrimitiveDictionaries.stringObj'");

    XCTAssertEqualObjects([unmanaged.intObj sumOfProperty:@"self"], @0);
    XCTAssertEqualObjects([optUnmanaged.intObj sumOfProperty:@"self"], @0);
    XCTAssertEqualObjects([managed.intObj sumOfProperty:@"self"], @0);
    XCTAssertEqualObjects([optManaged.intObj sumOfProperty:@"self"], @0);

    [self addObjects];

    XCTAssertEqualWithAccuracy([unmanaged.intObj sumOfProperty:@"self"].doubleValue, sum(@{@"0": @2, @"1": @3}), .001);
    XCTAssertEqualWithAccuracy([optUnmanaged.intObj sumOfProperty:@"self"].doubleValue, sum(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
    XCTAssertEqualWithAccuracy([managed.intObj sumOfProperty:@"self"].doubleValue, sum(@{@"0": @2, @"1": @3}), .001);
    XCTAssertEqualWithAccuracy([optManaged.intObj sumOfProperty:@"self"].doubleValue, sum(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
}

- (void)testAverage {
    RLMAssertThrowsWithReason([unmanaged.boolObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for bool array");
    RLMAssertThrowsWithReason([unmanaged.stringObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for string array");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for bool? array");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for string? array");
    RLMAssertThrowsWithReason([managed.boolObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for bool array 'AllPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([managed.stringObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for string array 'AllPrimitiveDictionaries.stringObj'");
    RLMAssertThrowsWithReason([optManaged.boolObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for bool? array 'AllOptionalPrimitiveDictionaries.boolObj'");
    RLMAssertThrowsWithReason([optManaged.stringObj averageOfProperty:@"self"],
                              @"averageOfProperty: is not supported for string? array 'AllOptionalPrimitiveDictionaries.stringObj'");

    XCTAssertNil([unmanaged.intObj averageOfProperty:@"self"]);
    XCTAssertNil([optUnmanaged.intObj averageOfProperty:@"self"]);
    XCTAssertNil([managed.intObj averageOfProperty:@"self"]);
    XCTAssertNil([optManaged.intObj averageOfProperty:@"self"]);

    [self addObjects];

    XCTAssertEqualWithAccuracy([unmanaged.intObj averageOfProperty:@"self"].doubleValue, average(@{@"0": @2, @"1": @3}), .001);
    XCTAssertEqualWithAccuracy([optUnmanaged.intObj averageOfProperty:@"self"].doubleValue, average(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
    XCTAssertEqualWithAccuracy([managed.intObj averageOfProperty:@"self"].doubleValue, average(@{@"0": @2, @"1": @3}), .001);
    XCTAssertEqualWithAccuracy([optManaged.intObj averageOfProperty:@"self"].doubleValue, average(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
}

- (void)testFastEnumeration {
    for (int i = 0; i < 10; ++i) {
        [self addObjects];
    }

    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @NO, @"1": @YES};
    for (id key in unmanaged.boolObj) {
    id value = unmanaged.boolObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, unmanaged.boolObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @2, @"1": @3};
    for (id key in unmanaged.intObj) {
    id value = unmanaged.intObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, unmanaged.intObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @"a", @"1": @"b"};
    for (id key in unmanaged.stringObj) {
    id value = unmanaged.stringObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, unmanaged.stringObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    for (id key in optUnmanaged.boolObj) {
    id value = optUnmanaged.boolObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optUnmanaged.boolObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @2, @"1": @3, @"2": NSNull.null};
    for (id key in optUnmanaged.intObj) {
    id value = optUnmanaged.intObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optUnmanaged.intObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    for (id key in optUnmanaged.stringObj) {
    id value = optUnmanaged.stringObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optUnmanaged.stringObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @NO, @"1": @YES};
    for (id key in managed.boolObj) {
    id value = managed.boolObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, managed.boolObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @2, @"1": @3};
    for (id key in managed.intObj) {
    id value = managed.intObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, managed.intObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @"a", @"1": @"b"};
    for (id key in managed.stringObj) {
    id value = managed.stringObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, managed.stringObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    for (id key in optManaged.boolObj) {
    id value = optManaged.boolObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optManaged.boolObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @2, @"1": @3, @"2": NSNull.null};
    for (id key in optManaged.intObj) {
    id value = optManaged.intObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optManaged.intObj.count);
    }
    
    {
    NSUInteger i = 0;
    NSDictionary *values = @{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    for (id key in optManaged.stringObj) {
    id value = optManaged.stringObj[key];
    XCTAssertEqualObjects(values[key], value);
    }
    XCTAssertEqual(i, optManaged.stringObj.count);
    }
    
}

- (void)testValueForKeySelf {
    for (RLMDictionary *dictionary in allDictionaries) {
        XCTAssertEqualObjects([dictionary valueForKey:@"self"], @[]);
    }

    [self addObjects];

    XCTAssertEqualObjects([unmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects([unmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    XCTAssertEqualObjects([unmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    XCTAssertEqualObjects([optUnmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    XCTAssertEqualObjects([optUnmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    XCTAssertEqualObjects([optUnmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    XCTAssertEqualObjects([managed.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects([managed.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    XCTAssertEqualObjects([managed.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    XCTAssertEqualObjects([optManaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    XCTAssertEqualObjects([optManaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    XCTAssertEqualObjects([optManaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
}

- (void)testValueForKeyNumericAggregates {
//    XCTAssertNil([unmanaged.intObj valueForKeyPath:@"@min.self"]);
//    XCTAssertNil([optUnmanaged.intObj valueForKeyPath:@"@min.self"]);
//    XCTAssertNil([managed.intObj valueForKeyPath:@"@min.self"]);
//    XCTAssertNil([optManaged.intObj valueForKeyPath:@"@min.self"]);
//    XCTAssertNil([unmanaged.intObj valueForKeyPath:@"@max.self"]);
//    XCTAssertNil([optUnmanaged.intObj valueForKeyPath:@"@max.self"]);
//    XCTAssertNil([managed.intObj valueForKeyPath:@"@max.self"]);
//    XCTAssertNil([optManaged.intObj valueForKeyPath:@"@max.self"]);
//    XCTAssertEqualObjects([unmanaged.intObj valueForKeyPath:@"@sum.self"], @0);
//    XCTAssertEqualObjects([optUnmanaged.intObj valueForKeyPath:@"@sum.self"], @0);
//    XCTAssertEqualObjects([managed.intObj valueForKeyPath:@"@sum.self"], @0);
//    XCTAssertEqualObjects([optManaged.intObj valueForKeyPath:@"@sum.self"], @0);
//    XCTAssertNil([unmanaged.intObj valueForKeyPath:@"@avg.self"]);
//    XCTAssertNil([optUnmanaged.intObj valueForKeyPath:@"@avg.self"]);
//    XCTAssertNil([managed.intObj valueForKeyPath:@"@avg.self"]);
//    XCTAssertNil([optManaged.intObj valueForKeyPath:@"@avg.self"]);
//
//    [self addObjects];
//
//    XCTAssertEqualObjects([unmanaged.intObj valueForKeyPath:@"@min.self"], @2);
//    XCTAssertEqualObjects([optUnmanaged.intObj valueForKeyPath:@"@min.self"], @2);
//    XCTAssertEqualObjects([managed.intObj valueForKeyPath:@"@min.self"], @2);
//    XCTAssertEqualObjects([optManaged.intObj valueForKeyPath:@"@min.self"], @2);
//    XCTAssertEqualObjects([unmanaged.intObj valueForKeyPath:@"@max.self"], @3);
//    XCTAssertEqualObjects([optUnmanaged.intObj valueForKeyPath:@"@max.self"], @3);
//    XCTAssertEqualObjects([managed.intObj valueForKeyPath:@"@max.self"], @3);
//    XCTAssertEqualObjects([optManaged.intObj valueForKeyPath:@"@max.self"], @3);
//    XCTAssertEqualWithAccuracy([[unmanaged.intObj valueForKeyPath:@"@sum.self"] doubleValue], sum(@{@"0": @2, @"1": @3}), .001);
//    XCTAssertEqualWithAccuracy([[optUnmanaged.intObj valueForKeyPath:@"@sum.self"] doubleValue], sum(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
//    XCTAssertEqualWithAccuracy([[managed.intObj valueForKeyPath:@"@sum.self"] doubleValue], sum(@{@"0": @2, @"1": @3}), .001);
//    XCTAssertEqualWithAccuracy([[optManaged.intObj valueForKeyPath:@"@sum.self"] doubleValue], sum(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
//    XCTAssertEqualWithAccuracy([[unmanaged.intObj valueForKeyPath:@"@avg.self"] doubleValue], average(@{@"0": @2, @"1": @3}), .001);
//    XCTAssertEqualWithAccuracy([[optUnmanaged.intObj valueForKeyPath:@"@avg.self"] doubleValue], average(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
//    XCTAssertEqualWithAccuracy([[managed.intObj valueForKeyPath:@"@avg.self"] doubleValue], average(@{@"0": @2, @"1": @3}), .001);
//    XCTAssertEqualWithAccuracy([[optManaged.intObj valueForKeyPath:@"@avg.self"] doubleValue], average(@{@"0": @2, @"1": @3, @"2": NSNull.null}), .001);
}

- (void)testValueForKeyLength {
    for (RLMDictionary *dictionary in allDictionaries) {
        XCTAssertEqualObjects([dictionary valueForKey:@"length"], @[]);
    }

    [self addObjects];

    XCTAssertEqualObjects([unmanaged.stringObj valueForKey:@"length"], ([@{@"0": @"a", @"1": @"b"} valueForKey:@"length"]));
    XCTAssertEqualObjects([optUnmanaged.stringObj valueForKey:@"length"], ([@{@"0": @"a", @"1": @"b", @"2": NSNull.null} valueForKey:@"length"]));
    XCTAssertEqualObjects([managed.stringObj valueForKey:@"length"], ([@{@"0": @"a", @"1": @"b"} valueForKey:@"length"]));
    XCTAssertEqualObjects([optManaged.stringObj valueForKey:@"length"], ([@{@"0": @"a", @"1": @"b", @"2": NSNull.null} valueForKey:@"length"]));
}

// Sort the distinct results to match the order used in values, as it
// doesn't preserve the order naturally
static NSArray *sortedDistinctUnion(id array, NSString *type, NSString *prop) {
    return [[array valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOf%@.%@", type, prop]]
            sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                bool aIsNull = a == NSNull.null;
                bool bIsNull = b == NSNull.null;
                if (aIsNull && bIsNull) {
                    return 0;
                }
                if (aIsNull) {
                    return 1;
                }
                if (bIsNull) {
                    return -1;
                }

                if ([a isKindOfClass:[NSData class]]) {
                    if ([a length] != [b length]) {
                        return [a length] < [b length] ? -1 : 1;
                    }
                    int result = memcmp([a bytes], [b bytes], [a length]);
                    if (!result) {
                        return 0;
                    }
                    return result < 0 ? -1 : 1;
                }

                if ([a isKindOfClass:[RLMObjectId class]]) {
                    int64_t idx1 = [objectIds indexOfObject:a];
                    int64_t idx2 = [objectIds indexOfObject:b];
                    return idx1 - idx2;
                }

                return [a compare:b];
            }];
}

- (void)testUnionOfObjects {
    for (RLMDictionary *dictionary in allDictionaries) {
        XCTAssertEqualObjects([dictionary valueForKeyPath:@"@unionOfObjects.self"], @[]);
    }
    for (RLMDictionary *dictionary in allDictionaries) {
        XCTAssertEqualObjects([dictionary valueForKeyPath:@"@distinctUnionOfObjects.self"], @[]);
    }

    [self addObjects];
    [self addObjects];

    XCTAssertEqualObjects([unmanaged.boolObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects([unmanaged.intObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @2, @"1": @4}));
    XCTAssertEqualObjects([unmanaged.stringObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @"a", @"1": @"de"}));
    XCTAssertEqualObjects([optUnmanaged.boolObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @YES, @"1": @NO}));
    XCTAssertEqualObjects([optUnmanaged.intObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @3, @"1": @4}));
    XCTAssertEqualObjects([optUnmanaged.stringObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @"bc", @"1": @"de"}));
    XCTAssertEqualObjects([managed.boolObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @YES, @"1": @NO}));
    XCTAssertEqualObjects([managed.intObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @3, @"1": @4}));
    XCTAssertEqualObjects([managed.stringObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @"bc", @"1": @"de"}));
    XCTAssertEqualObjects([optManaged.boolObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @YES, @"1": @NO}));
    XCTAssertEqualObjects([optManaged.intObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @3, @"1": @4}));
    XCTAssertEqualObjects([optManaged.stringObj valueForKeyPath:@"@unionOfObjects.self"],
                          (@{@"0": @"bc", @"1": @"de"}));
    XCTAssertEqualObjects(sortedDistinctUnion(unmanaged.boolObj, @"Objects", @"self"),
                          (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects(sortedDistinctUnion(unmanaged.intObj, @"Objects", @"self"),
                          (@{@"0": @2, @"1": @3}));
    XCTAssertEqualObjects(sortedDistinctUnion(unmanaged.stringObj, @"Objects", @"self"),
                          (@{@"0": @"a", @"1": @"b"}));
    XCTAssertEqualObjects(sortedDistinctUnion(optUnmanaged.boolObj, @"Objects", @"self"),
                          (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(optUnmanaged.intObj, @"Objects", @"self"),
                          (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(optUnmanaged.stringObj, @"Objects", @"self"),
                          (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(managed.boolObj, @"Objects", @"self"),
                          (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects(sortedDistinctUnion(managed.intObj, @"Objects", @"self"),
                          (@{@"0": @2, @"1": @3}));
    XCTAssertEqualObjects(sortedDistinctUnion(managed.stringObj, @"Objects", @"self"),
                          (@{@"0": @"a", @"1": @"b"}));
    XCTAssertEqualObjects(sortedDistinctUnion(optManaged.boolObj, @"Objects", @"self"),
                          (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(optManaged.intObj, @"Objects", @"self"),
                          (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(optManaged.stringObj, @"Objects", @"self"),
                          (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
}

- (void)testUnionOfArrays {
    RLMResults *allRequired = [AllPrimitiveDictionaries allObjectsInRealm:realm];
    RLMResults *allOptional = [AllOptionalPrimitiveDictionaries allObjectsInRealm:realm];

    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.boolObj"], @[]);
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.intObj"], @[]);
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.stringObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.boolObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.intObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.stringObj"], @[]);
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@distinctUnionOfArrays.boolObj"], @[]);
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@distinctUnionOfArrays.intObj"], @[]);
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@distinctUnionOfArrays.stringObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@distinctUnionOfArrays.boolObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@distinctUnionOfArrays.intObj"], @[]);
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@distinctUnionOfArrays.stringObj"], @[]);

    [self addObjects];

    [AllPrimitiveDictionaries createInRealm:realm withValue:managed];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:optManaged];

    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.boolObj"],
                          (@{@"0": @YES, @"1": @NO}));
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.intObj"],
                          (@{@"0": @3, @"1": @4}));
    XCTAssertEqualObjects([allRequired valueForKeyPath:@"@unionOfArrays.stringObj"],
                          (@{@"0": @"bc", @"1": @"de"}));
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.boolObj"],
                          (@{@"0": @YES, @"1": @NO}));
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.intObj"],
                          (@{@"0": @3, @"1": @4}));
    XCTAssertEqualObjects([allOptional valueForKeyPath:@"@unionOfArrays.stringObj"],
                          (@{@"0": @"bc", @"1": @"de"}));
    XCTAssertEqualObjects(sortedDistinctUnion(allRequired, @"Arrays", @"boolObj"),
                          (@{@"0": @NO, @"1": @YES}));
    XCTAssertEqualObjects(sortedDistinctUnion(allRequired, @"Arrays", @"intObj"),
                          (@{@"0": @2, @"1": @3}));
    XCTAssertEqualObjects(sortedDistinctUnion(allRequired, @"Arrays", @"stringObj"),
                          (@{@"0": @"a", @"1": @"b"}));
    XCTAssertEqualObjects(sortedDistinctUnion(allOptional, @"Arrays", @"boolObj"),
                          (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(allOptional, @"Arrays", @"intObj"),
                          (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    XCTAssertEqualObjects(sortedDistinctUnion(allOptional, @"Arrays", @"stringObj"),
                          (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
}

- (void)testSetValueForKey {
    for (RLMDictionary *dictionary in allDictionaries) {
        RLMAssertThrowsWithReason([dictionary setValue:@0 forKey:@"not self"],
                                  @"this class is not key value coding-compliant for the key not self.");
    }
    RLMAssertThrowsWithReason([unmanaged.boolObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj setValue:@2 forKey:@"self"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optUnmanaged.boolObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optUnmanaged.intObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optUnmanaged.stringObj setValue:@2 forKey:@"self"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([managed.boolObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj setValue:@2 forKey:@"self"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string'");
    RLMAssertThrowsWithReason([optManaged.boolObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'bool?'");
    RLMAssertThrowsWithReason([optManaged.intObj setValue:@"a" forKey:@"self"],
                              @"Invalid value 'a' of type '__NSCFConstantString' for expected type 'int?'");
    RLMAssertThrowsWithReason([optManaged.stringObj setValue:@2 forKey:@"self"],
                              @"Invalid value '2' of type '__NSCFNumber' for expected type 'string?'");
    RLMAssertThrowsWithReason([unmanaged.boolObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([unmanaged.intObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([unmanaged.stringObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");
    RLMAssertThrowsWithReason([managed.boolObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'bool'");
    RLMAssertThrowsWithReason([managed.intObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'int'");
    RLMAssertThrowsWithReason([managed.stringObj setValue:NSNull.null forKey:@"self"],
                              @"Invalid value '<null>' of type 'NSNull' for expected type 'string'");

    [self addObjects];

    [unmanaged.boolObj setValue:@NO forKey:@"self"];
    [unmanaged.intObj setValue:@2 forKey:@"self"];
    [unmanaged.stringObj setValue:@"a" forKey:@"self"];
    [optUnmanaged.boolObj setValue:@NO forKey:@"self"];
    [optUnmanaged.intObj setValue:@2 forKey:@"self"];
    [optUnmanaged.stringObj setValue:@"a" forKey:@"self"];
    [managed.boolObj setValue:@NO forKey:@"self"];
    [managed.intObj setValue:@2 forKey:@"self"];
    [managed.stringObj setValue:@"a" forKey:@"self"];
    [optManaged.boolObj setValue:@NO forKey:@"self"];
    [optManaged.intObj setValue:@2 forKey:@"self"];
    [optManaged.stringObj setValue:@"a" forKey:@"self"];

    XCTAssertEqualObjects(unmanaged.boolObj[0], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[0], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[0], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[0], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[0], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[0], @"a");
    XCTAssertEqualObjects(managed.boolObj[0], @NO);
    XCTAssertEqualObjects(managed.intObj[0], @2);
    XCTAssertEqualObjects(managed.stringObj[0], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[0], @NO);
    XCTAssertEqualObjects(optManaged.intObj[0], @2);
    XCTAssertEqualObjects(optManaged.stringObj[0], @"a");
    XCTAssertEqualObjects(unmanaged.boolObj[1], @NO);
    XCTAssertEqualObjects(unmanaged.intObj[1], @2);
    XCTAssertEqualObjects(unmanaged.stringObj[1], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[1], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[1], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[1], @"a");
    XCTAssertEqualObjects(managed.boolObj[1], @NO);
    XCTAssertEqualObjects(managed.intObj[1], @2);
    XCTAssertEqualObjects(managed.stringObj[1], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[1], @NO);
    XCTAssertEqualObjects(optManaged.intObj[1], @2);
    XCTAssertEqualObjects(optManaged.stringObj[1], @"a");
    XCTAssertEqualObjects(optUnmanaged.boolObj[2], @NO);
    XCTAssertEqualObjects(optUnmanaged.intObj[2], @2);
    XCTAssertEqualObjects(optUnmanaged.stringObj[2], @"a");
    XCTAssertEqualObjects(optManaged.boolObj[2], @NO);
    XCTAssertEqualObjects(optManaged.intObj[2], @2);
    XCTAssertEqualObjects(optManaged.stringObj[2], @"a");

    [optUnmanaged.boolObj setValue:NSNull.null forKey:@"self"];
    [optUnmanaged.intObj setValue:NSNull.null forKey:@"self"];
    [optUnmanaged.stringObj setValue:NSNull.null forKey:@"self"];
    [optManaged.boolObj setValue:NSNull.null forKey:@"self"];
    [optManaged.intObj setValue:NSNull.null forKey:@"self"];
    [optManaged.stringObj setValue:NSNull.null forKey:@"self"];
    XCTAssertEqualObjects(optUnmanaged.boolObj[0], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.intObj[0], NSNull.null);
    XCTAssertEqualObjects(optUnmanaged.stringObj[0], NSNull.null);
    XCTAssertEqualObjects(optManaged.boolObj[0], NSNull.null);
    XCTAssertEqualObjects(optManaged.intObj[0], NSNull.null);
    XCTAssertEqualObjects(optManaged.stringObj[0], NSNull.null);
}

- (void)testAssignment {
    unmanaged.boolObj = (id)@{@"testKey": @YES};
    XCTAssertEqualObjects(unmanaged.boolObj[@"testKey"], @YES);
    unmanaged.intObj = (id)@{@"testKey": @3};
    XCTAssertEqualObjects(unmanaged.intObj[@"testKey"], @3);
    unmanaged.stringObj = (id)@{@"testKey": @"b"};
    XCTAssertEqualObjects(unmanaged.stringObj[@"testKey"], @"b");
    optUnmanaged.boolObj = (id)@{@"testKey": @YES};
    XCTAssertEqualObjects(optUnmanaged.boolObj[@"testKey"], @YES);
    optUnmanaged.intObj = (id)@{@"testKey": @3};
    XCTAssertEqualObjects(optUnmanaged.intObj[@"testKey"], @3);
    optUnmanaged.stringObj = (id)@{@"testKey": @"b"};
    XCTAssertEqualObjects(optUnmanaged.stringObj[@"testKey"], @"b");
    managed.boolObj = (id)@{@"testKey": @YES};
    XCTAssertEqualObjects(managed.boolObj[@"testKey"], @YES);
    managed.intObj = (id)@{@"testKey": @3};
    XCTAssertEqualObjects(managed.intObj[@"testKey"], @3);
    managed.stringObj = (id)@{@"testKey": @"b"};
    XCTAssertEqualObjects(managed.stringObj[@"testKey"], @"b");
    optManaged.boolObj = (id)@{@"testKey": @YES};
    XCTAssertEqualObjects(optManaged.boolObj[@"testKey"], @YES);
    optManaged.intObj = (id)@{@"testKey": @3};
    XCTAssertEqualObjects(optManaged.intObj[@"testKey"], @3);
    optManaged.stringObj = (id)@{@"testKey": @"b"};
    XCTAssertEqualObjects(optManaged.stringObj[@"testKey"], @"b");

    // Should replace and not append
    unmanaged.boolObj = (id)@{@"0": @NO, @"1": @YES};
    XCTAssertEqualObjects([unmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    unmanaged.intObj = (id)@{@"0": @2, @"1": @3};
    XCTAssertEqualObjects([unmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    unmanaged.stringObj = (id)@{@"0": @"a", @"1": @"b"};
    XCTAssertEqualObjects([unmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optUnmanaged.boolObj = (id)@{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optUnmanaged.intObj = (id)@{@"0": @2, @"1": @3, @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optUnmanaged.stringObj = (id)@{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    
    managed.boolObj = (id)@{@"0": @NO, @"1": @YES};
    XCTAssertEqualObjects([managed.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    managed.intObj = (id)@{@"0": @2, @"1": @3};
    XCTAssertEqualObjects([managed.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    managed.stringObj = (id)@{@"0": @"a", @"1": @"b"};
    XCTAssertEqualObjects([managed.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optManaged.boolObj = (id)@{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optManaged.intObj = (id)@{@"0": @2, @"1": @3, @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optManaged.stringObj = (id)@{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    

    // Should not clear the array
    unmanaged.boolObj = unmanaged.boolObj;
    XCTAssertEqualObjects([unmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    unmanaged.intObj = unmanaged.intObj;
    XCTAssertEqualObjects([unmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    unmanaged.stringObj = unmanaged.stringObj;
    XCTAssertEqualObjects([unmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optUnmanaged.boolObj = optUnmanaged.boolObj;
    XCTAssertEqualObjects([optUnmanaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optUnmanaged.intObj = optUnmanaged.intObj;
    XCTAssertEqualObjects([optUnmanaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optUnmanaged.stringObj = optUnmanaged.stringObj;
    XCTAssertEqualObjects([optUnmanaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    
    managed.boolObj = managed.boolObj;
    XCTAssertEqualObjects([managed.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    managed.intObj = managed.intObj;
    XCTAssertEqualObjects([managed.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    managed.stringObj = managed.stringObj;
    XCTAssertEqualObjects([managed.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optManaged.boolObj = optManaged.boolObj;
    XCTAssertEqualObjects([optManaged.boolObj valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optManaged.intObj = optManaged.intObj;
    XCTAssertEqualObjects([optManaged.intObj valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optManaged.stringObj = optManaged.stringObj;
    XCTAssertEqualObjects([optManaged.stringObj valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    

    [unmanaged.intObj removeAllObjects];
    unmanaged.intObj = managed.intObj;
    XCTAssertEqualObjects([unmanaged.intObj valueForKey:@"self"], (@[@2, @3]));

    [managed.intObj removeAllObjects];
    managed.intObj = unmanaged.intObj;
    XCTAssertEqualObjects([managed.intObj valueForKey:@"self"], (@[@2, @3]));
}

- (void)testDynamicAssignment {
    unmanaged[@"boolObj"] = (id)@[@YES];
    XCTAssertEqualObjects(unmanaged[@"boolObj"][0], @YES);
    unmanaged[@"intObj"] = (id)@[@3];
    XCTAssertEqualObjects(unmanaged[@"intObj"][0], @3);
    unmanaged[@"stringObj"] = (id)@[@"b"];
    XCTAssertEqualObjects(unmanaged[@"stringObj"][0], @"b");
    optUnmanaged[@"boolObj"] = (id)@[@YES];
    XCTAssertEqualObjects(optUnmanaged[@"boolObj"][0], @YES);
    optUnmanaged[@"intObj"] = (id)@[@3];
    XCTAssertEqualObjects(optUnmanaged[@"intObj"][0], @3);
    optUnmanaged[@"stringObj"] = (id)@[@"b"];
    XCTAssertEqualObjects(optUnmanaged[@"stringObj"][0], @"b");
    managed[@"boolObj"] = (id)@[@YES];
    XCTAssertEqualObjects(managed[@"boolObj"][0], @YES);
    managed[@"intObj"] = (id)@[@3];
    XCTAssertEqualObjects(managed[@"intObj"][0], @3);
    managed[@"stringObj"] = (id)@[@"b"];
    XCTAssertEqualObjects(managed[@"stringObj"][0], @"b");
    optManaged[@"boolObj"] = (id)@[@YES];
    XCTAssertEqualObjects(optManaged[@"boolObj"][0], @YES);
    optManaged[@"intObj"] = (id)@[@3];
    XCTAssertEqualObjects(optManaged[@"intObj"][0], @3);
    optManaged[@"stringObj"] = (id)@[@"b"];
    XCTAssertEqualObjects(optManaged[@"stringObj"][0], @"b");

    // Should replace and not append
    unmanaged[@"boolObj"] = (id)@{@"0": @NO, @"1": @YES};
    XCTAssertEqualObjects([unmanaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    unmanaged[@"intObj"] = (id)@{@"0": @2, @"1": @3};
    XCTAssertEqualObjects([unmanaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    unmanaged[@"stringObj"] = (id)@{@"0": @"a", @"1": @"b"};
    XCTAssertEqualObjects([unmanaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optUnmanaged[@"boolObj"] = (id)@{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optUnmanaged[@"intObj"] = (id)@{@"0": @2, @"1": @3, @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optUnmanaged[@"stringObj"] = (id)@{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    XCTAssertEqualObjects([optUnmanaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    
    managed[@"boolObj"] = (id)@{@"0": @NO, @"1": @YES};
    XCTAssertEqualObjects([managed[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    managed[@"intObj"] = (id)@{@"0": @2, @"1": @3};
    XCTAssertEqualObjects([managed[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    managed[@"stringObj"] = (id)@{@"0": @"a", @"1": @"b"};
    XCTAssertEqualObjects([managed[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optManaged[@"boolObj"] = (id)@{@"0": @NO, @"1": @YES, @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optManaged[@"intObj"] = (id)@{@"0": @2, @"1": @3, @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optManaged[@"stringObj"] = (id)@{@"0": @"a", @"1": @"b", @"2": NSNull.null};
    XCTAssertEqualObjects([optManaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    

    // Should not clear the array
    unmanaged[@"boolObj"] = unmanaged[@"boolObj"];
    XCTAssertEqualObjects([unmanaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    unmanaged[@"intObj"] = unmanaged[@"intObj"];
    XCTAssertEqualObjects([unmanaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    unmanaged[@"stringObj"] = unmanaged[@"stringObj"];
    XCTAssertEqualObjects([unmanaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optUnmanaged[@"boolObj"] = optUnmanaged[@"boolObj"];
    XCTAssertEqualObjects([optUnmanaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optUnmanaged[@"intObj"] = optUnmanaged[@"intObj"];
    XCTAssertEqualObjects([optUnmanaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optUnmanaged[@"stringObj"] = optUnmanaged[@"stringObj"];
    XCTAssertEqualObjects([optUnmanaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    
    managed[@"boolObj"] = managed[@"boolObj"];
    XCTAssertEqualObjects([managed[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES}));
    
    managed[@"intObj"] = managed[@"intObj"];
    XCTAssertEqualObjects([managed[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3}));
    
    managed[@"stringObj"] = managed[@"stringObj"];
    XCTAssertEqualObjects([managed[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b"}));
    
    optManaged[@"boolObj"] = optManaged[@"boolObj"];
    XCTAssertEqualObjects([optManaged[@"boolObj"] valueForKey:@"self"], (@{@"0": @NO, @"1": @YES, @"2": NSNull.null}));
    
    optManaged[@"intObj"] = optManaged[@"intObj"];
    XCTAssertEqualObjects([optManaged[@"intObj"] valueForKey:@"self"], (@{@"0": @2, @"1": @3, @"2": NSNull.null}));
    
    optManaged[@"stringObj"] = optManaged[@"stringObj"];
    XCTAssertEqualObjects([optManaged[@"stringObj"] valueForKey:@"self"], (@{@"0": @"a", @"1": @"b", @"2": NSNull.null}));
    

    [unmanaged[@"intObj"] removeAllObjects];
    unmanaged[@"intObj"] = managed.intObj;
    XCTAssertEqualObjects([unmanaged[@"intObj"] valueForKey:@"self"], (@[@2, @3]));

    [managed[@"intObj"] removeAllObjects];
    managed[@"intObj"] = unmanaged.intObj;
    XCTAssertEqualObjects([managed[@"intObj"] valueForKey:@"self"], (@[@2, @3]));
}

- (void)testInvalidAssignment {
    RLMAssertThrowsWithReason(unmanaged.intObj = (id)@{@"0": NSNull.null},
                              @"Invalid value '<null>' of type 'NSNull' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged.intObj = (id)@{@"0": @"a"},
                              @"Invalid value 'a' of type '__NSCFConstantString' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged.intObj = (id)(@{@"0": @1, @"1": @"a"}),
                              @"Invalid value 'a' of type '__NSCFConstantString' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged.intObj = (id)unmanaged.floatObj,
                              @"RLMDictionary<string, float> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged.intObj = (id)optUnmanaged.intObj,
                              @"RLMDictionary<string, int?> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged[@"intObj"] = unmanaged[@"floatObj"],
                              @"RLMDictionary<string, float> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(unmanaged[@"intObj"] = optUnmanaged[@"intObj"],
                              @"RLMDictionary<string, int?> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");

    RLMAssertThrowsWithReason(managed.intObj = (id)@{@"0": NSNull.null},
                              @"Invalid value '<null>' of type 'NSNull' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed.intObj = (id)@{@"0": @"a"},
                              @"Invalid value 'a' of type '__NSCFConstantString' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed.intObj = (id)(@{@"0": @1, @"0": @"a"}),
                              @"Invalid value 'a' of type '__NSCFConstantString' for RLMDictionary<string, int> property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed.intObj = (id)managed.floatObj,
                              @"RLMDictionary<string, float> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed.intObj = (id)optManaged.intObj,
                              @"RLMDictionary<string, int?> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed[@"intObj"] = (id)managed[@"floatObj"],
                              @"RLMDictionary<string, float> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
    RLMAssertThrowsWithReason(managed[@"intObj"] = (id)optManaged[@"intObj"],
                              @"RLMDictionary<string, int?> does not match expected type RLMDictionary<string, int> for property 'AllPrimitiveDictionaries.intObj'.");
}

- (void)testAllMethodsCheckThread {
    RLMDictionary *dictionary = managed.intObj;
    [self dispatchAsyncAndWait:^{
        RLMAssertThrowsWithReason([dictionary count], @"thread");
        RLMAssertThrowsWithReason([dictionary objectAtIndex:0], @"thread");
        RLMAssertThrowsWithReason([dictionary firstObject], @"thread");
        RLMAssertThrowsWithReason([dictionary lastObject], @"thread");

        RLMAssertThrowsWithReason([dictionary setObject:@0 forKey:@"thread"], @"thread");
        RLMAssertThrowsWithReason([dictionary addObjects:@{@"thread": @0}], @"thread");
        RLMAssertThrowsWithReason([dictionary removeObjectForKey:@"thread"], @"thread");
        RLMAssertThrowsWithReason([dictionary removeObjectsForKeys:(id)@[@"thread"]], @"thread");
        RLMAssertThrowsWithReason([dictionary removeAllObjects], @"thread");
        RLMAssertThrowsWithReason([dictionary setObject:NSNull.null forKey:@"thread"], @"thread");

        RLMAssertThrowsWithReason([dictionary indexOfObject:@1], @"thread");
        /* RLMAssertThrowsWithReason([dictionary indexOfObjectWhere:@"TRUEPREDICATE"], @"thread"); */
        /* RLMAssertThrowsWithReason([dictionary indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]], @"thread"); */
        /* RLMAssertThrowsWithReason([dictionary objectsWhere:@"TRUEPREDICATE"], @"thread"); */
        /* RLMAssertThrowsWithReason([dictionary objectsWithPredicate:[NSPredicate predicateWithValue:NO]], @"thread"); */
        RLMAssertThrowsWithReason([dictionary sortedResultsUsingKeyPath:@"self" ascending:YES], @"thread");
        RLMAssertThrowsWithReason([dictionary sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"self" ascending:YES]]], @"thread");
        RLMAssertThrowsWithReason(dictionary[@"thread"], @"thread");
        RLMAssertThrowsWithReason(dictionary[@"thread"] = @0, @"thread");
        RLMAssertThrowsWithReason([dictionary valueForKey:@"self"], @"thread");
        RLMAssertThrowsWithReason([dictionary setValue:@1 forKey:@"self"], @"thread");
        RLMAssertThrowsWithReason({for (__unused id obj in dictionary);}, @"thread");
    }];
}

- (void)testAllMethodsCheckForInvalidation {
    RLMDictionary *dictionary = managed.intObj;
    [realm cancelWriteTransaction];
    [realm invalidate];

    XCTAssertNoThrow([dictionary objectClassName]);
    XCTAssertNoThrow([dictionary realm]);
    XCTAssertNoThrow([dictionary isInvalidated]);
    
    RLMAssertThrowsWithReason([dictionary count], @"invalidated");
    RLMAssertThrowsWithReason([dictionary objectAtIndex:0], @"invalidated");
    RLMAssertThrowsWithReason([dictionary firstObject], @"invalidated");
    RLMAssertThrowsWithReason([dictionary lastObject], @"invalidated");

    RLMAssertThrowsWithReason([dictionary setObject:@0 forKey:@"thread"], @"invalidated");
    RLMAssertThrowsWithReason([dictionary addObjects:@{@"invalidated": @0}], @"invalidated");
    RLMAssertThrowsWithReason([dictionary removeObjectForKey:@"invalidated"], @"invalidated");
    RLMAssertThrowsWithReason([dictionary removeObjectsForKeys:(id)@[@"invalidated"]], @"invalidated");
    RLMAssertThrowsWithReason([dictionary removeAllObjects], @"invalidated");
    RLMAssertThrowsWithReason([dictionary setObject:NSNull.null forKey:@"invalidated"], @"invalidated");

    RLMAssertThrowsWithReason([dictionary indexOfObject:@1], @"invalidated");
    /* RLMAssertThrowsWithReason([dictionary indexOfObjectWhere:@"TRUEPREDICATE"], @"invalidated"); */
    /* RLMAssertThrowsWithReason([dictionary indexOfObjectWithPredicate:[NSPredicate predicateWithValue:NO]], @"invalidated"); */
    /* RLMAssertThrowsWithReason([dictionary objectsWhere:@"TRUEPREDICATE"], @"invalidated"); */
    /* RLMAssertThrowsWithReason([dictionary objectsWithPredicate:[NSPredicate predicateWithValue:NO]], @"invalidated"); */
    RLMAssertThrowsWithReason([dictionary sortedResultsUsingKeyPath:@"self" ascending:YES], @"invalidated");
    RLMAssertThrowsWithReason([dictionary sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"self" ascending:YES]]], @"invalidated");
    RLMAssertThrowsWithReason(dictionary[@"invalidated"], @"invalidated");
    RLMAssertThrowsWithReason(dictionary[@"invalidated"] = @0, @"invalidated");
    RLMAssertThrowsWithReason([dictionary valueForKey:@"self"], @"invalidated");
    RLMAssertThrowsWithReason([dictionary setValue:@1 forKey:@"self"], @"invalidated");
    RLMAssertThrowsWithReason({for (__unused id obj in dictionary);}, @"invalidated");

    [realm beginWriteTransaction];
}

- (void)testMutatingMethodsCheckForWriteTransaction {
    RLMDictionary *dictionary = managed.intObj;
    [dictionary setObject:@0 forKey:@"testKey"];
    [realm commitWriteTransaction];

    XCTAssertNoThrow([dictionary objectClassName]);
    XCTAssertNoThrow([dictionary realm]);
    XCTAssertNoThrow([dictionary isInvalidated]);

    XCTAssertNoThrow([dictionary count]);
    XCTAssertNoThrow([dictionary objectAtIndex:0]);
    XCTAssertNoThrow([dictionary firstObject]);
    XCTAssertNoThrow([dictionary lastObject]);

    XCTAssertNoThrow([dictionary indexOfObject:@1]);
    /* XCTAssertNoThrow([dictionary indexOfObjectWhere:@"TRUEPREDICATE"]); */
    /* XCTAssertNoThrow([dictionary indexOfObjectWithPredicate:[NSPredicate predicateWithValue:YES]]); */
    /* XCTAssertNoThrow([dictionary objectsWhere:@"TRUEPREDICATE"]); */
    /* XCTAssertNoThrow([dictionary objectsWithPredicate:[NSPredicate predicateWithValue:YES]]); */
    XCTAssertNoThrow([dictionary sortedResultsUsingKeyPath:@"self" ascending:YES]);
    XCTAssertNoThrow([dictionary sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"self" ascending:YES]]]);
    XCTAssertNoThrow(dictionary[0]);
    XCTAssertNoThrow([dictionary valueForKey:@"self"]);
    XCTAssertNoThrow({for (__unused id obj in dictionary);});
    
    RLMAssertThrowsWithReason([dictionary setObject:@0 forKey:@"testKey"], @"write transaction");
    RLMAssertThrowsWithReason([dictionary addObjects:@{@"testKey": @0}], @"write transaction");
    RLMAssertThrowsWithReason([dictionary removeObjectForKey:@"testKey"], @"write transaction");
    RLMAssertThrowsWithReason([dictionary removeObjectsForKeys:(id)@[@"testKey"]], @"write transaction");
    RLMAssertThrowsWithReason([dictionary removeAllObjects], @"write transaction");
    RLMAssertThrowsWithReason([dictionary setObject:NSNull.null forKey:@"testKey"], @"write transaction");

    RLMAssertThrowsWithReason(dictionary[@"testKey"] = @0, @"write transaction");
    RLMAssertThrowsWithReason([dictionary setValue:@1 forKey:@"self"], @"write transaction");
}

- (void)testDeleteOwningObject {
    RLMDictionary *dictionary = managed.intObj;
    XCTAssertFalse(dictionary.isInvalidated);
    [realm deleteObject:managed];
    XCTAssertTrue(dictionary.isInvalidated);
}

#pragma clang diagnostic ignored "-Warc-retain-cycles"

- (void)testNotificationSentInitially {
    [realm commitWriteTransaction];

    id expectation = [self expectationWithDescription:@""];
    id token = [managed.intObj addNotificationBlock:^(RLMDictionary *dictionary, RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(dictionary);
        XCTAssertNil(change);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationSentAfterCommit {
    [realm commitWriteTransaction];

    __block bool first = true;
    __block id expectation = [self expectationWithDescription:@""];
    id token = [managed.intObj addNotificationBlock:^(RLMDictionary *dictionary, RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(dictionary);
        XCTAssertNil(error);
        if (first) {
            XCTAssertNil(change);
        }
        else {
            XCTAssertEqualObjects(change.insertions, @[@0]);
        }

        first = false;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    expectation = [self expectationWithDescription:@""];
    [self dispatchAsyncAndWait:^{
        RLMRealm *r = [RLMRealm defaultRealm];
        [r transactionWithBlock:^{
            RLMDictionary *dictionary = [(AllPrimitiveDictionaries *)[AllPrimitiveDictionaries allObjectsInRealm:r].firstObject intObj];
            dictionary[@"testKey"] = @0;
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationNotSentForUnrelatedChange {
    [realm commitWriteTransaction];

    id expectation = [self expectationWithDescription:@""];
    id token = [managed.intObj addNotificationBlock:^(__unused RLMDictionary *dictionary, __unused RLMCollectionChange *change, __unused NSError *error) {
        // will throw if it's incorrectly called a second time due to the
        // unrelated write transaction
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // All notification blocks are called as part of a single runloop event, so
    // waiting for this one also waits for the above one to get a chance to run
    [self waitForNotification:RLMRealmDidChangeNotification realm:realm block:^{
        [self dispatchAsyncAndWait:^{
            RLMRealm *r = [RLMRealm defaultRealm];
            [r transactionWithBlock:^{
                [AllPrimitiveDictionaries createInRealm:r withValue:@[]];
            }];
        }];
    }];
    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationSentOnlyForActualRefresh {
    [realm commitWriteTransaction];

    __block id expectation = [self expectationWithDescription:@""];
    id token = [managed.intObj addNotificationBlock:^(RLMDictionary *dictionary, __unused RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(dictionary);
        XCTAssertNil(error);
        // will throw if it's called a second time before we create the new
        // expectation object immediately before manually refreshing
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // Turn off autorefresh, so the background commit should not result in a notification
    realm.autorefresh = NO;

    // All notification blocks are called as part of a single runloop event, so
    // waiting for this one also waits for the above one to get a chance to run
    [self waitForNotification:RLMRealmRefreshRequiredNotification realm:realm block:^{
        [self dispatchAsyncAndWait:^{
            RLMRealm *r = [RLMRealm defaultRealm];
            [r transactionWithBlock:^{
                RLMDictionary *dictionary = [(AllPrimitiveDictionaries *)[AllPrimitiveDictionaries allObjectsInRealm:r].firstObject intObj];
                dictionary[@"testKey"] = @0;
            }];
        }];
    }];

    expectation = [self expectationWithDescription:@""];
    [realm refresh];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [(RLMNotificationToken *)token invalidate];
}

- (void)testDeletingObjectWithNotificationsRegistered {
    [managed.intObj addObjects:@{@"a": @10, @"b": @20}];
    [realm commitWriteTransaction];

    __block bool first = true;
    __block id expectation = [self expectationWithDescription:@""];
    id token = [managed.intObj addNotificationBlock:^(RLMDictionary *dictionary, RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(dictionary);
        XCTAssertNil(error);
        if (first) {
            XCTAssertNil(change);
            first = false;
        }
        else {
            XCTAssertEqualObjects(change.deletions, (@[@0, @1]));
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [realm beginWriteTransaction];
    [realm deleteObject:managed];
    [realm commitWriteTransaction];

    expectation = [self expectationWithDescription:@""];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [(RLMNotificationToken *)token invalidate];
}

#pragma mark - Queries

#define RLMAssertCount(cls, expectedCount, ...) \
    XCTAssertEqual(expectedCount, ([cls objectsInRealm:realm where:__VA_ARGS__].count))

- (void)createObjectWithKey:(NSString *)key {
    id boolObj = [@{@"0": @NO, @"1": @YES} dictionaryWithValuesForKeys:@[key]];
    id intObj = [@{@"0": @2, @"1": @3} dictionaryWithValuesForKeys:@[key]];
    id stringObj = [@{@"0": @"a", @"1": @"b"} dictionaryWithValuesForKeys:@[key]];
    
    id obj = [AllPrimitiveDictionaries createInRealm:realm withValue: @{
        @"boolObj": boolObj,
        @"intObj": intObj,
        @"stringObj": stringObj,
    }];
    [LinkToAllPrimitiveDictionaries createInRealm:realm withValue:@[obj]];
    obj = [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": boolObj,
        @"intObj": intObj,
        @"stringObj": stringObj,
    }];
    [LinkToAllOptionalPrimitiveDictionaries createInRealm:realm withValue:@[obj]];
}

- (void)testQueryBasicOperators {
    [realm deleteAllObjects];

    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj = %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj = %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj != %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj != %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj > %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj > %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj <= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj <= %@", @2);

    [self createObjectWithKey:@"0"];

    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj = %@", @YES);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj = %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj = %@", @"b");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj = %@", @YES);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj = %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj = %@", @"b");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj = %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj = %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj != %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj != %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj != %@", @YES);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj != %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"b");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj != %@", @YES);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj != %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"b");
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj > %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj > %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj < %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj < %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj <= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj <= %@", @2);

    [self createObjectWithKey:@"1"];

    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj = %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj = %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj = %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj = %@", @YES);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj = %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"b");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj = %@", @YES);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj = %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj = %@", @"b");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj != %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj != %@", @NO);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj != %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"a");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj != %@", @YES);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj != %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"b");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj != %@", @YES);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj != %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj != %@", @"b");
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj > %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj > %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2, @"ANY intObj >= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj < %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj < %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj < %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj <= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj <= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2, @"ANY intObj <= %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2, @"ANY intObj <= %@", @3);

    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"ANY boolObj > %@", @NO]),
                              @"Operator '>' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"ANY stringObj > %@", @"a"]),
                              @"Operator '>' not supported for type 'string'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY boolObj > %@", @NO]),
                              @"Operator '>' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY stringObj > %@", @"a"]),
                              @"Operator '>' not supported for type 'string'");
}

- (void)testQueryBetween {
    [realm deleteAllObjects];

    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"ANY boolObj BETWEEN %@", @[@NO, @YES]]),
                              @"Operator 'BETWEEN' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"ANY stringObj BETWEEN %@", @[@"a", @"b"]]),
                              @"Operator 'BETWEEN' not supported for type 'string'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY boolObj BETWEEN %@", @[@NO, @YES]]),
                              @"Operator 'BETWEEN' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY stringObj BETWEEN %@", @[@"a", @"b"]]),
                              @"Operator 'BETWEEN' not supported for type 'string'");

    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj BETWEEN %@", @[@2, @3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj BETWEEN %@", @[@2, @3]);

    [self createObjectWithKey:@"0"];

    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj BETWEEN %@", @[@2, @2]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj BETWEEN %@", @[@2, @2]);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj BETWEEN %@", @[@2, @3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj BETWEEN %@", @[@2, @3]);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj BETWEEN %@", @[@3, @3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj BETWEEN %@", @[@3, @3]);
}

- (void)testQueryIn {
    [realm deleteAllObjects];

    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj IN %@", @[@NO, @YES]);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj IN %@", @[@2, @3]);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj IN %@", @[@"a", @"b"]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj IN %@", @[@NO, @YES]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj IN %@", @[@2, @3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj IN %@", @[@"a", @"b"]);

    [self createObjectWithKey:@"0"];

    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY boolObj IN %@", @[@YES]);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY intObj IN %@", @[@3]);
    RLMAssertCount(AllPrimitiveDictionaries, 0, @"ANY stringObj IN %@", @[@"b"]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY boolObj IN %@", @[@YES]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY intObj IN %@", @[@3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0, @"ANY stringObj IN %@", @[@"b"]);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY boolObj IN %@", @[@NO, @YES]);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY intObj IN %@", @[@2, @3]);
    RLMAssertCount(AllPrimitiveDictionaries, 1, @"ANY stringObj IN %@", @[@"a", @"b"]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY boolObj IN %@", @[@NO, @YES]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY intObj IN %@", @[@2, @3]);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1, @"ANY stringObj IN %@", @[@"a", @"b"]);
}

- (void)testQueryCount {
    [realm deleteAllObjects];

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[],
        @"intObj": @[],
        @"stringObj": @[],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[],
        @"intObj": @[],
        @"stringObj": @[],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[@NO],
        @"intObj": @[@2],
        @"stringObj": @[@"a"],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[@NO],
        @"intObj": @[@2],
        @"stringObj": @[@"a"],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[@NO, @NO],
        @"intObj": @[@2, @2],
        @"stringObj": @[@"a", @"a"],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"boolObj": @[@NO, @NO],
        @"intObj": @[@2, @2],
        @"stringObj": @[@"a", @"a"],
    }];

    for (unsigned int i = 0; i < 3; ++i) {
        RLMAssertCount(AllPrimitiveDictionaries, 1U, @"boolObj.@count == %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@count == %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 1U, @"stringObj.@count == %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"boolObj.@count == %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@count == %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"stringObj.@count == %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2U, @"boolObj.@count != %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@count != %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2U, @"stringObj.@count != %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"boolObj.@count != %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@count != %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"stringObj.@count != %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2 - i, @"boolObj.@count > %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2 - i, @"intObj.@count > %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 2 - i, @"stringObj.@count > %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2 - i, @"boolObj.@count > %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2 - i, @"intObj.@count > %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 2 - i, @"stringObj.@count > %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 3 - i, @"boolObj.@count >= %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 3 - i, @"intObj.@count >= %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, 3 - i, @"stringObj.@count >= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 3 - i, @"boolObj.@count >= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 3 - i, @"intObj.@count >= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, 3 - i, @"stringObj.@count >= %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i, @"boolObj.@count < %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i, @"intObj.@count < %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i, @"stringObj.@count < %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i, @"boolObj.@count < %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i, @"intObj.@count < %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i, @"stringObj.@count < %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i + 1, @"boolObj.@count <= %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i + 1, @"intObj.@count <= %@", @(i));
        RLMAssertCount(AllPrimitiveDictionaries, i + 1, @"stringObj.@count <= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i + 1, @"boolObj.@count <= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i + 1, @"intObj.@count <= %@", @(i));
        RLMAssertCount(AllOptionalPrimitiveDictionaries, i + 1, @"stringObj.@count <= %@", @(i));
    }
}

- (void)testQuerySum {
    [realm deleteAllObjects];


    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum = %@", @"a"]),
                              @"@sum on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum = %@", @"a"]),
                              @"@sum on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllPrimitiveDictionaries'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllOptionalPrimitiveDictionaries'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum = %@", NSNull.null]),
                              @"@sum on a property of type int cannot be compared with '<null>'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@sum = %@", NSNull.null]),
                              @"@sum on a property of type int cannot be compared with '<null>'");

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @2],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @2, @2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @2, @2],
    }];

    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@sum == %@", @0);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@sum == %@", @0);
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@sum == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@sum == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 3U, @"intObj.@sum != %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 3U, @"intObj.@sum != %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 3U, @"intObj.@sum >= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 3U, @"intObj.@sum >= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@sum > %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@sum > %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@sum < %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@sum < %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@sum <= %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@sum <= %@", @3);
}

- (void)testQueryAverage {
    [realm deleteAllObjects];


    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@avg = %@", @"a"]),
                              @"@avg on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@avg = %@", @"a"]),
                              @"@avg on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@avg.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllPrimitiveDictionaries'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@avg.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllOptionalPrimitiveDictionaries'");

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @3],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@2, @3],
    }];
    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3],
    }];

    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@avg == %@", NSNull.null);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@avg == %@", NSNull.null);
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@avg == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@avg == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 3U, @"intObj.@avg != %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 3U, @"intObj.@avg != %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 3U, @"intObj.@avg >= %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 3U, @"intObj.@avg >= %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@avg > %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@avg > %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@avg < %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@avg < %@", @3);
    RLMAssertCount(AllPrimitiveDictionaries, 3U, @"intObj.@avg <= %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 3U, @"intObj.@avg <= %@", @3);
}

- (void)testQueryMin {
    [realm deleteAllObjects];

    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"boolObj.@min = %@", @NO]),
                              @"@min can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"stringObj.@min = %@", @"a"]),
                              @"@min can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"boolObj.@min = %@", @NO]),
                              @"@min can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"stringObj.@min = %@", @"a"]),
                              @"@min can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@min = %@", @"a"]),
                              @"@min on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@min = %@", @"a"]),
                              @"@min on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@min.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllPrimitiveDictionaries'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@min.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllOptionalPrimitiveDictionaries'");

    // No objects, so count is zero
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@min == %@", @2);

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{}];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{}];

    // Only empty arrays, so count is zero
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@min == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@min == %@", @3);

    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == nil");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == nil");
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == %@", NSNull.null);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == %@", NSNull.null);

    [self createObjectWithKey:@"0"];

    // One object where v0 is min and zero with v1
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@min == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@min == %@", @3);

    [self createObjectWithKey:@"1"];

    // One object where v0 is min and one with v1
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == %@", @3);

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3, @2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3, @2],
    }];

    // New object with both v0 and v1 matches v0 but not v1
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@min == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@min == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@min == %@", @3);
}

- (void)testQueryMax {
    [realm deleteAllObjects];

    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"boolObj.@max = %@", @NO]),
                              @"@max can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"stringObj.@max = %@", @"a"]),
                              @"@max can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"boolObj.@max = %@", @NO]),
                              @"@max can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"stringObj.@max = %@", @"a"]),
                              @"@max can only be applied to a numeric property.");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@max = %@", @"a"]),
                              @"@max on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@max = %@", @"a"]),
                              @"@max on a property of type int cannot be compared with 'a'");
    RLMAssertThrowsWithReason(([AllPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@max.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllPrimitiveDictionaries'");
    RLMAssertThrowsWithReason(([AllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"intObj.@max.prop = %@", @"a"]),
                              @"Property 'intObj' is not a link in object of type 'AllOptionalPrimitiveDictionaries'");

    // No objects, so count is zero
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@max == %@", @2);

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{}];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{}];

    // Only empty arrays, so count is zero
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@max == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@max == %@", @3);

    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == nil");
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == nil");
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == %@", NSNull.null);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == %@", NSNull.null);

    [self createObjectWithKey:@"0"];

    // One object where v0 is min and zero with v1
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 0U, @"intObj.@max == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 0U, @"intObj.@max == %@", @3);

    [self createObjectWithKey:@"1"];

    // One object where v0 is min and one with v1
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == %@", @3);

    [AllPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3, @2],
    }];
    [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
        @"intObj": @[@3, @2],
    }];

    // New object with both v0 and v1 matches v1 but not v0
    RLMAssertCount(AllPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 1U, @"intObj.@max == %@", @2);
    RLMAssertCount(AllPrimitiveDictionaries, 2U, @"intObj.@max == %@", @3);
    RLMAssertCount(AllOptionalPrimitiveDictionaries, 2U, @"intObj.@max == %@", @3);
}

- (void)testQueryBasicOperatorsOverLink {
    [realm deleteAllObjects];

    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj <= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj <= %@", @2);

    [self createObjectWithKey:@"0"];

    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.boolObj = %@", @YES);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj = %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.stringObj = %@", @"b");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.boolObj = %@", @YES);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj = %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.stringObj = %@", @"b");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @YES);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"b");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @YES);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"b");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj < %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj < %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj <= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj <= %@", @2);

    [self createObjectWithKey:@"1"];

    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @YES);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"b");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj = %@", @YES);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj = %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj = %@", @"b");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @NO);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"a");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @YES);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"b");
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.boolObj != %@", @YES);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj != %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.stringObj != %@", @"b");
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj > %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 2, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 2, @"ANY link.intObj >= %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 0, @"ANY link.intObj < %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj < %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj < %@", @3);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 1, @"ANY link.intObj <= %@", @2);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 1, @"ANY link.intObj <= %@", @2);
    RLMAssertCount(LinkToAllPrimitiveDictionaries, 2, @"ANY link.intObj <= %@", @3);
    RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, 2, @"ANY link.intObj <= %@", @3);

    RLMAssertThrowsWithReason(([LinkToAllPrimitiveDictionaries objectsInRealm:realm where:@"ANY link.boolObj > %@", @NO]),
                              @"Operator '>' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([LinkToAllPrimitiveDictionaries objectsInRealm:realm where:@"ANY link.stringObj > %@", @"a"]),
                              @"Operator '>' not supported for type 'string'");
    RLMAssertThrowsWithReason(([LinkToAllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY link.boolObj > %@", @NO]),
                              @"Operator '>' not supported for type 'bool'");
    RLMAssertThrowsWithReason(([LinkToAllOptionalPrimitiveDictionaries objectsInRealm:realm where:@"ANY link.stringObj > %@", @"a"]),
                              @"Operator '>' not supported for type 'string'");
}

- (void)testSubstringQueries {
    NSArray *values = @[
        @"",

        @"á", @"ó", @"ú",

        @"áá", @"áó", @"áú",
        @"óá", @"óó", @"óú",
        @"úá", @"úó", @"úú",

        @"ááá", @"ááó", @"ááú", @"áóá", @"áóó", @"áóú", @"áúá", @"áúó", @"áúú",
        @"óáá", @"óáó", @"óáú", @"óóá", @"óóó", @"óóú", @"óúá", @"óúó", @"óúú",
        @"úáá", @"úáó", @"úáú", @"úóá", @"úóó", @"úóú", @"úúá", @"úúó", @"úúú",
    ];

    void (^create)(NSString *) = ^(NSString *value) {
        id obj = [AllPrimitiveDictionaries createInRealm:realm withValue:@{
            @"stringObj": @[value],
            @"dataObj": @[[value dataUsingEncoding:NSUTF8StringEncoding]]
        }];
        [LinkToAllPrimitiveDictionaries createInRealm:realm withValue:@[obj]];
        obj = [AllOptionalPrimitiveDictionaries createInRealm:realm withValue:@{
            @"stringObj": @[value],
            @"dataObj": @[[value dataUsingEncoding:NSUTF8StringEncoding]]
        }];
        [LinkToAllOptionalPrimitiveDictionaries createInRealm:realm withValue:@[obj]];
    };

    for (NSString *value in values) {
        create(value);
        create(value.uppercaseString);
        create([value stringByApplyingTransform:NSStringTransformStripDiacritics reverse:NO]);
        create([value.uppercaseString stringByApplyingTransform:NSStringTransformStripDiacritics reverse:NO]);
    }

    void (^test)(NSString *, id, NSUInteger) = ^(NSString *operator, NSString *value, NSUInteger count) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];

        NSString *query = [NSString stringWithFormat:@"ANY stringObj %@ %%@", operator];
        RLMAssertCount(AllPrimitiveDictionaries, count, query, value);
        RLMAssertCount(AllOptionalPrimitiveDictionaries, count, query, value);
        query = [NSString stringWithFormat:@"ANY link.stringObj %@ %%@", operator];
        RLMAssertCount(LinkToAllPrimitiveDictionaries, count, query, value);
        RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, count, query, value);

        query = [NSString stringWithFormat:@"ANY dataObj %@ %%@", operator];
        RLMAssertCount(AllPrimitiveDictionaries, count, query, data);
        RLMAssertCount(AllOptionalPrimitiveDictionaries, count, query, data);
        query = [NSString stringWithFormat:@"ANY link.dataObj %@ %%@", operator];
        RLMAssertCount(LinkToAllPrimitiveDictionaries, count, query, data);
        RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, count, query, data);
    };
    void (^testNull)(NSString *, NSUInteger) = ^(NSString *operator, NSUInteger count) {
        NSString *query = [NSString stringWithFormat:@"ANY stringObj %@ nil", operator];
        RLMAssertThrowsWithReason([AllPrimitiveDictionaries objectsInRealm:realm where:query],
                                  @"Expected object of type string for property 'stringObj' on object of type 'AllPrimitiveDictionaries', but received: (null)");
        RLMAssertCount(AllOptionalPrimitiveDictionaries, count, query, NSNull.null);
        query = [NSString stringWithFormat:@"ANY link.stringObj %@ nil", operator];
        RLMAssertThrowsWithReason([LinkToAllPrimitiveDictionaries objectsInRealm:realm where:query],
                                  @"Expected object of type string for property 'link.stringObj' on object of type 'LinkToAllPrimitiveDictionaries', but received: (null)");
        RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, count, query, NSNull.null);

        query = [NSString stringWithFormat:@"ANY dataObj %@ nil", operator];
        RLMAssertThrowsWithReason([AllPrimitiveDictionaries objectsInRealm:realm where:query],
                                  @"Expected object of type data for property 'dataObj' on object of type 'AllPrimitiveDictionaries', but received: (null)");
        RLMAssertCount(AllOptionalPrimitiveDictionaries, count, query, NSNull.null);

        query = [NSString stringWithFormat:@"ANY link.dataObj %@ nil", operator];
        RLMAssertThrowsWithReason([LinkToAllPrimitiveDictionaries objectsInRealm:realm where:query],
                                  @"Expected object of type data for property 'link.dataObj' on object of type 'LinkToAllPrimitiveDictionaries', but received: (null)");
        RLMAssertCount(LinkToAllOptionalPrimitiveDictionaries, count, query, NSNull.null);
    };

    // Core's implementation of case-insensitive comparisons only works for
    // unaccented a-z, so the diacritic-sensitive, case-insensitive queries
    // match half as many as they should. Many of the below tests will start
    // failing if this is fixed.

    testNull(@"==", 0);
    test(@"==", @"", 4);
    test(@"==", @"a", 1);
    test(@"==", @"á", 1);
    test(@"==[c]", @"a", 2);
    test(@"==[c]", @"á", 1);
    test(@"==", @"A", 1);
    test(@"==", @"Á", 1);
    test(@"==[c]", @"A", 2);
    test(@"==[c]", @"Á", 1);
    test(@"==[d]", @"a", 2);
    test(@"==[d]", @"á", 2);
    test(@"==[cd]", @"a", 4);
    test(@"==[cd]", @"á", 4);
    test(@"==[d]", @"A", 2);
    test(@"==[d]", @"Á", 2);
    test(@"==[cd]", @"A", 4);
    test(@"==[cd]", @"Á", 4);

    testNull(@"!=", 160);
    test(@"!=", @"", 156);
    test(@"!=", @"a", 159);
    test(@"!=", @"á", 159);
    test(@"!=[c]", @"a", 158);
    test(@"!=[c]", @"á", 159);
    test(@"!=", @"A", 159);
    test(@"!=", @"Á", 159);
    test(@"!=[c]", @"A", 158);
    test(@"!=[c]", @"Á", 159);
    test(@"!=[d]", @"a", 158);
    test(@"!=[d]", @"á", 158);
    test(@"!=[cd]", @"a", 156);
    test(@"!=[cd]", @"á", 156);
    test(@"!=[d]", @"A", 158);
    test(@"!=[d]", @"Á", 158);
    test(@"!=[cd]", @"A", 156);
    test(@"!=[cd]", @"Á", 156);

    testNull(@"CONTAINS", 0);
    testNull(@"CONTAINS[c]", 0);
    testNull(@"CONTAINS[d]", 0);
    testNull(@"CONTAINS[cd]", 0);
    test(@"CONTAINS", @"a", 25);
    test(@"CONTAINS", @"á", 25);
    test(@"CONTAINS[c]", @"a", 50);
    test(@"CONTAINS[c]", @"á", 25);
    test(@"CONTAINS", @"A", 25);
    test(@"CONTAINS", @"Á", 25);
    test(@"CONTAINS[c]", @"A", 50);
    test(@"CONTAINS[c]", @"Á", 25);
    test(@"CONTAINS[d]", @"a", 50);
    test(@"CONTAINS[d]", @"á", 50);
    test(@"CONTAINS[cd]", @"a", 100);
    test(@"CONTAINS[cd]", @"á", 100);
    test(@"CONTAINS[d]", @"A", 50);
    test(@"CONTAINS[d]", @"Á", 50);
    test(@"CONTAINS[cd]", @"A", 100);
    test(@"CONTAINS[cd]", @"Á", 100);

    test(@"BEGINSWITH", @"a", 13);
    test(@"BEGINSWITH", @"á", 13);
    test(@"BEGINSWITH[c]", @"a", 26);
    test(@"BEGINSWITH[c]", @"á", 13);
    test(@"BEGINSWITH", @"A", 13);
    test(@"BEGINSWITH", @"Á", 13);
    test(@"BEGINSWITH[c]", @"A", 26);
    test(@"BEGINSWITH[c]", @"Á", 13);
    test(@"BEGINSWITH[d]", @"a", 26);
    test(@"BEGINSWITH[d]", @"á", 26);
    test(@"BEGINSWITH[cd]", @"a", 52);
    test(@"BEGINSWITH[cd]", @"á", 52);
    test(@"BEGINSWITH[d]", @"A", 26);
    test(@"BEGINSWITH[d]", @"Á", 26);
    test(@"BEGINSWITH[cd]", @"A", 52);
    test(@"BEGINSWITH[cd]", @"Á", 52);

    test(@"ENDSWITH", @"a", 13);
    test(@"ENDSWITH", @"á", 13);
    test(@"ENDSWITH[c]", @"a", 26);
    test(@"ENDSWITH[c]", @"á", 13);
    test(@"ENDSWITH", @"A", 13);
    test(@"ENDSWITH", @"Á", 13);
    test(@"ENDSWITH[c]", @"A", 26);
    test(@"ENDSWITH[c]", @"Á", 13);
    test(@"ENDSWITH[d]", @"a", 26);
    test(@"ENDSWITH[d]", @"á", 26);
    test(@"ENDSWITH[cd]", @"a", 52);
    test(@"ENDSWITH[cd]", @"á", 52);
    test(@"ENDSWITH[d]", @"A", 26);
    test(@"ENDSWITH[d]", @"Á", 26);
    test(@"ENDSWITH[cd]", @"A", 52);
    test(@"ENDSWITH[cd]", @"Á", 52);
}

@end
