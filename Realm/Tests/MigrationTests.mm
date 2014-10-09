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

extern "C" {
#import "RLMTestCase.h"
}
#import "RLMMigration.h"
#import "RLMObjectSchema_Private.hpp"
#import "RLMProperty_Private.h"
#import "RLMRealm_Dynamic.h"
#import "RLMSchema_Private.h"

@interface MigrationObject : RLMObject
@property int intCol;
@property NSString *stringCol;
@end

@implementation MigrationObject
@end

@interface MigrationPrimaryKeyObject : RLMObject
@property int intCol;
@end

@implementation MigrationPrimaryKeyObject
+ (NSString *)primaryKey {
    return @"intCol";
}
@end

@interface MigrationTests : RLMTestCase
@end

@implementation MigrationTests

- (RLMRealm *)realmWithSingleObject:(RLMObjectSchema *)objectSchema {
    // modify object schema to use RLMObject class (or else bad accessors will get created)
    objectSchema.objectClass = RLMObject.class;

    RLMSchema *schema = [[RLMSchema alloc] init];
    schema.objectSchema = @[objectSchema];
    return [self dynamicRealmWithTestPathAndSchema:schema];
}

- (void)testAddingProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    objectSchema.properties = @[objectSchema.properties[0]];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1]];
    [realm createObject:MigrationObject.className withObject:@[@2]];
    [realm commitWriteTransaction];

    // open realm with new schema before migration to test migration is necessary
    objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    XCTAssertThrows([self realmWithTestPath], @"Migration should be required");
    
    // apply migration
    [RLMRealm registerMigrationBlock:^NSUInteger(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                              block:^(RLMObject *oldObject, RLMObject *newObject) {
            XCTAssertThrows(oldObject[@"stringCol"], @"stringCol should not exist on old object");
            NSNumber *intObj;
            XCTAssertNoThrow(intObj = oldObject[@"intCol"], @"Should be able to access intCol on oldObject");
            NSString *stringObj = [NSString stringWithFormat:@"%@", intObj];
            XCTAssertNoThrow(newObject[@"stringCol"] = stringObj, @"Should be able to set stringCol");
        }];
        return 1;
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertEqual(mig1.intCol, 2, @"Int column should have value 2");
    XCTAssertEqualObjects(mig1.stringCol, @"2", @"String column should be populated");
}


- (void)testRemoveProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *thirdProperty = [[RLMProperty alloc] initWithName:@"deletedCol" type:RLMPropertyTypeBool objectClassName:nil attributes:(RLMPropertyAttributes)0];
    thirdProperty.column = 2;
    objectSchema.properties = [objectSchema.properties arrayByAddingObject:thirdProperty];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @"1", @YES]];
    [realm createObject:MigrationObject.className withObject:@[@2, @"2", @NO]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm registerMigrationBlock:^NSUInteger(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                                       block:^(RLMObject *oldObject, RLMObject *newObject) {
            XCTAssertNoThrow(oldObject[@"deletedCol"], @"Deleted column should be accessible on old object.");
            XCTAssertThrows(newObject[@"deletedCol"], @"Deleted column should not be accessible on new object.");
        }];
        return 1;
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertThrows(mig1[@"deletedCol"], @"Deleted column should no longer be accessible.");
}

- (void)testRemoveAndAddProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *oldInt = [[RLMProperty alloc] initWithName:@"oldIntCol" type:RLMPropertyTypeInt objectClassName:nil attributes:(RLMPropertyAttributes)0];
    objectSchema.properties = @[oldInt, objectSchema.properties[1]];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @"1"]];
    [realm createObject:MigrationObject.className withObject:@[@1, @"2"]];
    [realm commitWriteTransaction];

    // object migration object
    void (^migrateObjectBlock)(RLMObject *, RLMObject *) = ^(RLMObject *oldObject, RLMObject *newObject) {
        XCTAssertNoThrow(oldObject[@"oldIntCol"], @"Deleted column should be accessible on old object.");
        XCTAssertThrows(oldObject[@"intCol"], @"New column should not be accessible on old object.");
        XCTAssertEqual([oldObject[@"oldIntCol"] intValue], 1, @"Deleted column value is correct.");
        XCTAssertNoThrow(newObject[@"intCol"], @"New column is accessible on new object.");
        XCTAssertThrows(newObject[@"oldIntCol"], @"Old column should not be accessible on old object.");
        XCTAssertEqual([newObject[@"intCol"] intValue], 0, @"New column value is uninitialized.");
    };

    // apply migration
    [RLMRealm registerMigrationBlock:^NSUInteger(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className block:migrateObjectBlock];
        return 1;
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertThrows(mig1[@"deletedCol"], @"Deleted column should no longer be accessible.");
}

- (void)testChangePropertyType {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *stringCol = objectSchema.properties[1];
    stringCol.type = RLMPropertyTypeInt;
    stringCol.objcType = 'i';

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @1]];
    [realm createObject:MigrationObject.className withObject:@[@2, @2]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm registerMigrationBlock:^NSUInteger(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                                       block:^(RLMObject *oldObject, RLMObject *newObject) {
            NSNumber *intObj = oldObject[@"stringCol"];
            XCTAssert([intObj isKindOfClass:NSNumber.class], @"Old stringCol should be int");
            newObject[@"stringCol"] = intObj.stringValue;
        }];
        return 1;
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertEqualObjects(mig1[@"stringCol"], @"2", @"stringCol should be string after migration.");
}

- (void)testPrimaryKeyMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm registerMigrationBlock:^NSUInteger(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        return 1;
    }];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()],
                    @"Migration should throw due to duplicate primary keys)");

    [RLMRealm registerMigrationBlock:^NSUInteger(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        __block int objectID = 0;
        [migration enumerateObjects:@"MigrationPrimaryKeyObject" block:^(__unused RLMObject *oldObject, RLMObject *newObject) {
            newObject[@"intCol"] = @(objectID++);
        }];
        return 1;
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
}

- (void)testVersionNumberCanStaySameWithNoSchemaChanges {
    @autoreleasepool { [self dynamicRealmWithTestPathAndSchema:[RLMSchema sharedSchema]]; }

    [RLMRealm registerMigrationBlock:^NSUInteger(__unused RLMMigration *migration, NSUInteger oldSchemaVersion) {
        return oldSchemaVersion;
    }];
    XCTAssertNoThrow([RLMRealm migrateRealmAtPath:RLMTestRealmPath()]);
}

- (void)testVersionNumberMustIncreaseWithSchemaChanges {
    @autoreleasepool {
        // make string an int
        RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
        RLMProperty *stringCol = objectSchema.properties[1];
        stringCol.type = RLMPropertyTypeInt;
        stringCol.objcType = 'i';

        // create realm with old schema and populate
        RLMRealm *realm = [self realmWithSingleObject:objectSchema];
        [realm beginWriteTransaction];
        [realm createObject:MigrationObject.className withObject:@[@1, @1]];
        [realm commitWriteTransaction];
    }

    [RLMRealm registerMigrationBlock:^NSUInteger(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        [migration enumerateObjects:MigrationObject.className block:^(RLMObject *, RLMObject *newObject) {
            newObject[@"stringCol"] = @"";
        }];
        return oldSchemaVersion;
    }];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()]);
}

@end

