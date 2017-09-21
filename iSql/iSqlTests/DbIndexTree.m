//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DbIndexTree.h"

@interface DbIndexTreeTest : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *files;

@end

@implementation DbIndexTreeTest

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
	Db1IndexTree *tree = [[Db1IndexTree alloc] init:@"test"];
	[tree add:1 value:1];
	[tree add:1 value:2];
	[tree add:2 value:1];
	[tree add:2 value:2];
	[tree add:2 value:3];
	[tree add:3 value:5];
	[tree add:4 value:2];
	[tree add:4 value:4];
	[tree add:4 value:6];
	IdArray *values = [tree get:1];
	for (NSInteger n = 0 ; n < values.count ; n++) {
		uint64_t value = [values get:n];
		NSLog(@"%lld", value);
	}
}

- (bool)hasDbIndexTreeStructureData:(NSString*)name
{
    NSData *data = [self readDbIndexTreeStructureData:name];
    return data != 0;
}

- (NSData*)readDbIndexTreeStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    NSData *data = [files valueForKey:path];
    return data;
}

- (NSData*)readDbIndexTreeNodeData:(NSString*)name id:(uint64_t)id cached:(bool)cached
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data;
}

- (bool)writeDbIndexTreeNodeData:(NSString*)name id:(uint64_t)id data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files setValue:data forKey:path];
    return true;
}

- (bool)writeDbIndexTreeStructureData:(NSString*)name data:(NSData*)data
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files setValue:data forKey:path];
    return true;
}

- (bool)removeDbIndexTreeStructureData:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"%@.db", name];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasDbIndexTreeNodeData:(NSString*)name id:(uint64_t)id;
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    NSData *data = [files valueForKey:path];
    return data != nil;
}

- (bool)removeDbIndexTreeNodeData:(NSString*)name id:(uint64_t)id
{
    NSString *path = [NSString stringWithFormat:@"%@.%lld.db", name, id];
    [files removeObjectForKey:path];
    return true;
}

- (bool)hasDbIndexTreeRecoveryData
{
    return [self readDbIndexTreeRecoveryData] != nil;
}

- (NSData*)readDbIndexTreeRecoveryData
{
    return [files valueForKey:@"recovery.db"];
}

- (bool)writeDbIndexTreeRecoveryData:(NSData*)data
{
	[files setValue:data forKey:@"recovery.db"];
	return true;
}

- (bool)removeDbIndexTreeRecoveryData
{
    [files removeObjectForKey:@"recovery.db"];
    return true;
}

@end
