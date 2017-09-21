//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DbIdTree.h"

@interface DbIdTreeTest : XCTestCase <DbIdTreeStorageDelegate>

@property (nonatomic, strong) NSMutableDictionary *files;

@end

@implementation DbIdTreeTest

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

- (void)testInsertRemove
{
    {
        DbIdTree *test = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:nil];
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

- (void)testStress
{
	NSUInteger max = 16 * 1024;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger n = 0 ; n < max ; n++) {
		array[n] = [NSNumber numberWithUnsignedInteger:n];
	}
	DbIdTree *test = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:nil];
	{
		NSMutableArray *aux = [array mutableCopy];
		for (NSUInteger n = 0 ; n < max ; n++) {
			NSUInteger index = rand() % aux.count;
			NSNumber *number = aux[index];
			[aux removeObjectAtIndex:index];
			XCTAssertTrue([test add:[number intValue] value:number]);
		}
	}
	{
		for (NSUInteger n = 0 ; n < max ; n++) {
			XCTAssertTrue([[test get:n] isEqual:[NSNumber numberWithUnsignedInteger:n]]);
		}
	}
	{
		NSMutableArray *aux = [array mutableCopy];
		for (NSUInteger n = 0 ; n < max ; n++) {
			NSUInteger index = rand() % aux.count;
			NSNumber *number = aux[index];
			[aux removeObjectAtIndex:index];
			XCTAssertTrue([[test get:[number intValue]] isEqual:number]);
		}
	}
	{
		NSMutableArray *aux = [array mutableCopy];
		for (NSUInteger n = 0 ; n < max ; n++) {
			NSUInteger index = rand() % aux.count;
			NSNumber *number = aux[index];
			[aux removeObjectAtIndex:index];
			XCTAssertTrue([test remove:[number intValue]]);
		}
	}
	
}

- (void)testRecovery
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree add:1 value:@1];
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
    }
}

- (void)testCommit
{
    DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
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
    DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
    XCTAssertEqualObjects(@" 1", [tree string]);
}

- (void)testCommitAndReadStress
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        for (int n = 1 ; n <= 1024 ; n++) {
            [tree add:n value:[NSNumber numberWithInt:n]];
        }
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        for (int n = 1 ; n <= 1024 ; n++) {
            XCTAssertEqualObjects([NSNumber numberWithInt:n], [tree get:n]);
        }
    }
}

- (void)testCommitAndErrorReadRecovery
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
    }
}

- (void)testCommitWithRecoveryReadRecovery
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
    }
}

- (void)testCommits
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        [tree add:1 value:@1];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
        [tree add:2 value:@2];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitsAndErrorReadRecovery
{
    {
        {
            DbIdTree *tree1 = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
            [tree1 add:1 value:@1];
            [tree1 write];
        }
        {
            DbIdTree *tree2 = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
            [tree2 add:2 value:@2];
            [tree2 write];
        }
    }
    {
        DbIdTree *tree1 = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        DbIdTree *tree2 = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
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
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        XCTAssertEqualObjects(@1, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitsWithRecovery
{
    {
        {
            DbIdTree *tree1 = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
            [tree1 add:1 value:@1];
            [tree1 write];
        }
        {
            DbIdTree *tree2 = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
            [tree2 add:2 value:@2];
            [tree2 write];
        }
    }
    {
        DbIdTree *tree1 = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        DbIdTree *tree2 = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
        [tree1 set:1 value:@2];
        XCTAssertEqualObjects(@2, [tree1 get:1]);
        NSMutableData *recoveryData = [[NSMutableData alloc] init];
        [recoveryData appendData:[tree1 recovery]];
        [recoveryData appendData:[tree2 recovery]];
        [recoveryData appendUByte:0xFF];
        [files setValue:recoveryData forKey:@"recovery.db"];
        [tree1 write];
        [tree2 write];
        [self removeDbIdTreeRecoveryData];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test1" withStorageDelegate:self];
        XCTAssertEqualObjects(@2, [tree get:1]);
        XCTAssertNil([tree get:2]);
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test2" withStorageDelegate:self];
        XCTAssertNil([tree get:1]);
        XCTAssertEqualObjects(@2, [tree get:2]);
    }
}

- (void)testCommitAndReadDicStress
{
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        for (int n = 1 ; n <= 32 ; n++) {
            [tree add:n value:@{@"id": [NSNumber numberWithInt:n]}];
        }
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
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
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
        [tree add:1 value:@{@"id": [NSNumber numberWithInt:1], @"name": @"Bernardo"}];
        [tree add:2 value:@{@"id": [NSNumber numberWithInt:2], @"name": @"Breder"}];
        [tree write];
    }
    {
        DbIdTree *tree = [[DbIdTree alloc] initNamed:@"test" withStorageDelegate:self];
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

- (bool)hasDbIdTreeStructureData:(NSString*)name
{
    NSData *data = [self readDbIdTreeStructureData:name];
    return data != 0;
}

- (NSData*)readDbIdTreeStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    NSData *data = [files valueForKey:path];
    return data;
}

- (NSData*)readDbIdTreeNodeData:(NSString*)name id:(uint64_t)id cached:(bool)cached
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data;
}

- (bool)writeDbIdTreeNodeData:(NSString*)name id:(uint64_t)id data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files setValue:data forKey:path];
    return true;
}

- (bool)writeDbIdTreeStructureData:(NSString*)name data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files setValue:data forKey:path];
    return true;
}

- (bool)removeDbIdTreeStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasDbIdTreeNodeData:(NSString*)name id:(uint64_t)id;
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data != nil;
}

- (bool)removeDbIdTreeNodeData:(NSString*)name id:(uint64_t)id
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasDbIdTreeRecoveryData
{
    return [self readDbIdTreeRecoveryData] != nil;
}

- (NSData*)readDbIdTreeRecoveryData
{
    return [files valueForKey:@"recovery.db"];
}

- (bool)writeDbIdTreeRecoveryData:(NSData*)data
{
	[files setValue:data forKey:@"recovery.db"];
	return true;
}

- (bool)removeDbIdTreeRecoveryData
{
    [files removeObjectForKey:@"recovery.db"];
    return true;
}

@end
