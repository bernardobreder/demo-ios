//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DbConnection.h"

@interface DbConnectionTest : XCTestCase <DbTreeMemoryDelegate, DbTreeStorageDelegate>

@property (nonatomic, strong) NSMutableDictionary *files;

@end

@implementation DbConnectionTest

@synthesize files;

- (void)setUp
{
    [super setUp];
    files = [[NSMutableDictionary alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCreateTable
{
    DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
    DbTable *personTable = [connection table:@"person"];
    XCTAssertTrue([personTable create]);
    XCTAssertTrue([connection commit]);
}

- (void)testSearchId
{
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        [personTable create];
        [personTable insert:@{@"id": @1, @"name": @"Bernardo"}];
        XCTAssertTrue([connection commit]);
    }
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        NSDictionary *person1 = [personTable search:1];
        XCTAssertNotNil(person1);
        [connection rollback];
    }
}

- (void)testSearchIdList
{
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        [personTable create];
        [personTable insert:@{@"id": @1, @"name": @"Bernardo"}];
        [personTable insert:@{@"id": @2, @"name": @"Breder"}];
        [personTable insert:@{@"id": @3, @"name": @"Test"}];
        [personTable insert:@{@"id": @4, @"name": @"Banco de Dados"}];
        XCTAssertTrue([connection commit]);
    }
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        XCTAssertNotNil([personTable search:1]);
        XCTAssertNotNil([personTable search:2]);
        XCTAssertNotNil([personTable search:3]);
        XCTAssertNotNil([personTable search:4]);
        XCTAssertEqualObjects(@"Bernardo", [personTable search:1][@"name"]);
        XCTAssertEqualObjects(@"Breder", [personTable search:2][@"name"]);
        XCTAssertEqualObjects(@"Test", [personTable search:3][@"name"]);
        XCTAssertEqualObjects(@"Banco de Dados", [personTable search:4][@"name"]);
        [connection rollback];
    }
}

- (void)_testSearchPersonAndPhone
{
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        [personTable create];
        [personTable insert:@{@"id": @1, @"name": @"Bernardo"}];
        [personTable insert:@{@"id": @2, @"name": @"Breder"}];
        DbTable *phoneTable = [connection table:@"phone"];
        [phoneTable create];
        [[phoneTable index:@[@"person_id"]] create];
        XCTAssertTrue([connection commit]);
    }
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *phoneTable = [connection table:@"phone"];
        [phoneTable insert:@{@"person_id": @1, @"number": @"1234-5678"}];
        [phoneTable insert:@{@"person_id": @2, @"number": @"8765-4321"}];
        XCTAssertTrue([connection commit]);
    }
    {
        DbConnection* connection = [[DbConnection alloc] initWithMemoryDelegate:self withStorageDelegate:self];
        DbTable *personTable = [connection table:@"person"];
        DbTable *phoneTable = [connection table:@"phone"];
        XCTAssertNotNil([personTable search:1]);
        XCTAssertNotNil([personTable search:2]);
        XCTAssertNotNil([[phoneTable index:@[@"person_id"]] search:@[@1]]);
        XCTAssertNotNil([[phoneTable index:@[@"person_id"]] search:@[@2]]);
        XCTAssertEqualObjects(@"Bernardo", [personTable search:1][@"name"]);
        XCTAssertEqualObjects(@"Breder", [personTable search:2][@"name"]);
        XCTAssertEqualObjects(@"1234-5678", [[phoneTable index:@[@"person_id"]] search:@[@1]][@"number"]);
        XCTAssertEqualObjects(@"8765-4321", [[phoneTable index:@[@"person_id"]] search:@[@2]][@"number"]);
        [connection rollback];
    }
}


- (bool)hasStructureData:(NSString*)name
{
    NSData *data = [self readStructureData:name];
    return data != 0;
}

- (NSData*)readStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    NSData *data = [files valueForKey:path];
    return data;
}

- (NSData*)readNodeData:(NSString*)name id:(uint64_t)id cached:(bool)cached
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data;
}

- (bool)writeNodeData:(NSString*)name id:(uint64_t)id data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files setValue:data forKey:path];
    return true;
}

- (bool)writeStructureData:(NSString*)name data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files setValue:data forKey:path];
    return true;
}

- (bool)removeStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasNodeData:(NSString*)name id:(uint64_t)id;
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data != nil;
}

- (bool)removeNodeData:(NSString*)name id:(uint64_t)id
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasRecoveryData
{
    return [self readRecoveryData] != nil;
}

- (NSData*)readRecoveryData
{
    return [files valueForKey:@"recovery.db"];
}

- (bool)removeRecoveryData
{
    [files removeObjectForKey:@"recovery.db"];
    return true;
}

- (bool)writeRecoveryData:(NSData*)data
{
	[files setValue:data forKey:@"recovery.db"];
	return true;
}

@end
