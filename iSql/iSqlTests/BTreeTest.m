//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface DbTreeTest : XCTestCase <DbTreeStorageDelegate, DbTreeMemoryDelegate>

@property (nonatomic, strong) NSMutableDictionary *files;

@property (nonatomic, assign) NSInteger nodesInMemory;

@end

@implementation DbTreeTest

@synthesize files;
@synthesize nodesInMemory;

- (void)setUp
{
    [super setUp];
    files = [[NSMutableDictionary alloc] init];
    nodesInMemory = 0;
}

- (void)tearDown
{
    [super tearDown];
    XCTAssertEqual(0, nodesInMemory);
}

- (void)testInsertRemove
{
    {
        DbTree *test = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:nil];
        [test add:1 value:@1]; XCTAssertEqualObjects(@" 1", [test string]);
        [test add:3 value:@3]; XCTAssertEqualObjects(@" 1 3", [test string]);
        [test add:7 value:@7]; XCTAssertEqualObjects(@" 1 3 7", [test string]);
        [test add:10 value:@10]; XCTAssertEqualObjects(@" 1 3 7 10", [test string]);
        [test add:11 value:@11]; XCTAssertEqualObjects(@" 1 3 7 10 11", [test string]);
        [test add:13 value:@13]; XCTAssertEqualObjects(@" 1 3 7 10 11 13", [test string]);
        [test add:14 value:@14]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14", [test string]);
        [test add:15 value:@15]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15", [test string]);
        [test add:18 value:@18]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 18", [test string]);
        [test add:16 value:@16]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18", [test string]);
        [test add:19 value:@19]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18 19", [test string]);
        [test add:24 value:@24]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18 19 24", [test string]);
        [test add:25 value:@25]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18 19 24 25", [test string]);
        [test add:26 value:@26]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18 19 24 25 26", [test string]);
        [test add:21 value:@21]; XCTAssertEqualObjects(@" 1 3 7 10 11 13 14 15 16 18 19 21 24 25 26", [test string]);
        [test add:4 value:@4]; XCTAssertEqualObjects(@" 1 3 4 7 10 11 13 14 15 16 18 19 21 24 25 26", [test string]);
        [test add:5 value:@5]; XCTAssertEqualObjects(@" 1 3 4 5 7 10 11 13 14 15 16 18 19 21 24 25 26", [test string]);
        [test add:20 value:@20]; XCTAssertEqualObjects(@" 1 3 4 5 7 10 11 13 14 15 16 18 19 20 21 24 25 26", [test string]);
        [test add:22 value:@22]; XCTAssertEqualObjects(@" 1 3 4 5 7 10 11 13 14 15 16 18 19 20 21 22 24 25 26", [test string]);
        [test add:2 value:@2]; XCTAssertEqualObjects(@" 1 2 3 4 5 7 10 11 13 14 15 16 18 19 20 21 22 24 25 26", [test string]);
        [test add:17 value:@17]; XCTAssertEqualObjects(@" 1 2 3 4 5 7 10 11 13 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test add:12 value:@12]; XCTAssertEqualObjects(@" 1 2 3 4 5 7 10 11 12 13 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test add:6 value:@6]; XCTAssertEqualObjects(@" 1 2 3 4 5 6 7 10 11 12 13 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:6]; XCTAssertEqualObjects(@" 1 2 3 4 5 7 10 11 12 13 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:13]; XCTAssertEqualObjects(@" 1 2 3 4 5 7 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:7]; XCTAssertEqualObjects(@" 1 2 3 4 5 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:4]; XCTAssertEqualObjects(@" 1 2 3 5 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:2]; XCTAssertEqualObjects(@" 1 3 5 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:16]; XCTAssertEqualObjects(@" 1 3 5 10 11 12 14 15 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:11]; XCTAssertEqualObjects(@" 1 3 5 10 12 14 15 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:3]; XCTAssertEqualObjects(@" 1 5 10 12 14 15 17 18 19 20 21 22 24 25 26", [test string]);
        [test remove:20]; XCTAssertEqualObjects(@" 1 5 10 12 14 15 17 18 19 21 22 24 25 26", [test string]);
        [test remove:25]; XCTAssertEqualObjects(@" 1 5 10 12 14 15 17 18 19 21 22 24 26", [test string]);
        [test remove:5]; XCTAssertEqualObjects(@" 1 10 12 14 15 17 18 19 21 22 24 26", [test string]);
        [test remove:1]; XCTAssertEqualObjects(@" 10 12 14 15 17 18 19 21 22 24 26", [test string]);
        [test remove:12]; XCTAssertEqualObjects(@" 10 14 15 17 18 19 21 22 24 26", [test string]);
        [test remove:14]; XCTAssertEqualObjects(@" 10 15 17 18 19 21 22 24 26", [test string]);
        [test remove:26]; XCTAssertEqualObjects(@" 10 15 17 18 19 21 22 24", [test string]);
        [test remove:15]; XCTAssertEqualObjects(@" 10 17 18 19 21 22 24", [test string]);
        [test remove:19]; XCTAssertEqualObjects(@" 10 17 18 21 22 24", [test string]);
        [test remove:21]; XCTAssertEqualObjects(@" 10 17 18 22 24", [test string]);
        [test remove:22]; XCTAssertEqualObjects(@" 10 17 18 24", [test string]);
        [test remove:10]; XCTAssertEqualObjects(@" 17 18 24", [test string]);
        [test remove:18]; XCTAssertEqualObjects(@" 17 24", [test string]);
        [test remove:24]; XCTAssertEqualObjects(@" 17", [test string]);
        [test remove:17]; XCTAssertEqualObjects(@"", [test string]);
    }
}

- (void)testRecovery
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:1 value:@1];
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
    }
}

- (void)testCommit
{
    DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
    [tree add:1 value:@1];
    NSMutableData *recoveryData = [[NSMutableData alloc] init];
    [recoveryData appendData:[tree recovery]];
    [recoveryData appendUByte:0xFF];
    [files setValue:recoveryData forKey:@"recovery.db"];
    [tree write];
    [files removeObjectForKey:@"recovery.db"];
}

- (void)testCommitAndRead
{
    [self testCommit];
    DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
    XCTAssertEqualObjects(@" 1", [tree string]);
}

- (void)testCommitAndReadStress
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        for (int n = 1 ; n <= 1024 ; n++) {
            [tree add:n value:[NSNumber numberWithInt:n]];
        }
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        for (int n = 1 ; n <= 1024 ; n++) {
            XCTAssertEqualObjects([NSNumber numberWithInt:n], [tree get:n]);
        }
    }
}

- (void)testCommitAndErrorReadRecovery
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
    }
}

- (void)testCommitWithRecoveryReadRecovery
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
    }
}

- (void)testCommits
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:2 value:@2];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitsAndErrorReadRecovery
{
    {
        {
            DbTree *tree1 = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
            [tree1 add:1 value:@1];
            [tree1 write];
        }
        {
            DbTree *tree2 = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
            [tree2 add:2 value:@2];
            [tree2 write];
        }
    }
    {
        DbTree *tree1 = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        DbTree *tree2 = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        [tree1 set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree1 get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree1 recovery]];
        [recoveryData appendData:[tree2 recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
        [tree1 write];
        [tree2 write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitsWithRecovery
{
    {
        {
            DbTree *tree1 = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
            [tree1 add:1 value:@1];
            [tree1 write];
        }
        {
            DbTree *tree2 = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
            [tree2 add:2 value:@2];
            [tree2 write];
        }
    }
    {
        DbTree *tree1 = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        DbTree *tree2 = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        [tree1 set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree1 get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree1 recovery]];
        [recoveryData appendData:[tree2 recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
        [tree1 write];
        [tree2 write];
        [self removeRecoveryData];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test1" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertEqualObjects(@2, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test2" withMemoryDelegate:self withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitAndReadDicStress
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        for (int n = 1 ; n <= 32 ; n++) {
            [tree add:n value:@{@"id": [NSNumber numberWithInt:n]}];
        }
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        for (int n = 1 ; n <= 32 ; n++) {
            NSDictionary *dic = (NSDictionary*)[tree get:n];
            XCTAssertNotNil(dic);
            XCTAssertEqualObjects([NSNumber numberWithInt:n], dic[@"id"]);
        }
    }
}

- (void)testCommitAndReadDic
{
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        [tree add:1 value:@{@"id": [NSNumber numberWithInt:1], @"name": @"Bernardo"}];
        [tree add:2 value:@{@"id": [NSNumber numberWithInt:2], @"name": @"Breder"}];
        [tree write];
    }
    {
        DbTree *tree = [[DbTree alloc] initNamed:@"test" withMemoryDelegate:self withStorageDelegate:self];
        NSDictionary *dic1 = (NSDictionary*)[tree get:1];
        NSDictionary *dic2 = (NSDictionary*)[tree get:2];
        XCTAssertNotNil(dic1);
        XCTAssertNotNil(dic2);
        XCTAssertEqualObjects([NSNumber numberWithInt:1], dic1[@"id"]);
        XCTAssertEqualObjects([NSNumber numberWithInt:2], dic2[@"id"]);
        XCTAssertEqualObjects(@"Bernardo", dic1[@"name"]);
        XCTAssertEqualObjects(@"Breder", dic2[@"name"]);
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

- (bool)writeRecoveryData:(NSData*)data
{
	[files setValue:data forKey:@"recovery.db"];
	return true;
}

- (bool)removeRecoveryData
{
    [files removeObjectForKey:@"recovery.db"];
    return true;
}

- (DbTreeNode*)allocNode
{
    nodesInMemory++;
    return [[DbTreeNode alloc] init];
}

- (void)freeNode:(DbTreeNode*)node
{
    nodesInMemory--;
}

@end
