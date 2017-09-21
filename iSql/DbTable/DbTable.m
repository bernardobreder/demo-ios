//
//  DbTable.m
//  iSql
//
//  Created by Bernardo Breder on 25/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "DbTable.h"

@interface DbTable ()

@property (nonatomic, strong) DbConnection *connection;

@property (nonatomic, weak, readonly) id<DbTreeMemoryDelegate> memoryDelegate;

@property (nonatomic, weak, readonly) id<DbTreeStorageDelegate> storageDelegate;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) DbTree *tree;

@property (nonatomic, strong) NSMutableDictionary *indexDictionary;

@end

@interface DbIndex ()

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSArray *index;

@property (nonatomic, strong) DbTree *tree;

- (bool)insert:(NSDictionary*)value;

@end

@implementation DbTable

@synthesize connection = _connection;

@synthesize memoryDelegate = _memoryDelegate;

@synthesize storageDelegate = _storageDelegate;

@synthesize name = _name;

@synthesize tree = _tree;

@synthesize indexDictionary = _indexDictionary;

- (id)initWithName:(NSString*)name connection:(DbConnection*)connection withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate
{
	if (!(self = [super init])) return nil;
	_connection = connection;
	_memoryDelegate = memoryDelegate;
	_storageDelegate = storageDelegate;
	_name = name;
	if (!(_tree = [[DbTree alloc] initNamed:name withMemoryDelegate:memoryDelegate withStorageDelegate:storageDelegate])) {
		return nil;
	}
	if (!(_indexDictionary = [[NSMutableDictionary alloc] init])) {
		return nil;
	}
	return self;
}

- (bool)create
{
	_tree.changed = true;
	return true;
}

- (bool)drop
{
	return false;
}

- (DbIndex*)index:(NSArray*)indexs
{
	DbIndex *index = _indexDictionary[indexs];
	if (!index) {
		NSMutableString *name = [[NSMutableString alloc] init];
		[name appendString:_name];
		[name appendString:@"("];
		for (NSUInteger n = 0; n < indexs.count ; n++) {
			[name appendString:indexs[n]];
			if (n != indexs.count - 1) {
				[name appendString:@","];
			}
		}
		[name appendString:@")"];
		index = [[DbIndex alloc] initWithName:name index:indexs withMemoryDelegate:_memoryDelegate withStorageDelegate:_storageDelegate];
		_indexDictionary[indexs] = index;
	}
	return index;
}

- (NSDictionary*)search:(uint64_t)id
{
	NSDictionary *dic = (NSDictionary*)[_tree get:id];
	return dic;
}

- (bool)insert:(NSDictionary*)value
{
	if ([value objectForKey:@"id"]) {
		NSNumber *idNumber = (NSNumber*)value[@"id"];
		uint64_t id = [idNumber unsignedLongLongValue];
		if ([_tree has:id]) {
			if (![_tree set:id value:value]) {
				return false;
			}
		} else {
			if (![_tree add:id value:value]) {
				return false;
			}
		}
	} else {
		uint64_t id = _tree.count + 1;
		if (![_tree add:id value:value]) {
			return false;
		}
	}
	for (NSArray *indexKey in [_indexDictionary keyEnumerator]) {
		DbIndex *index = _indexDictionary[indexKey];
	}
	return true;
}

- (bool)update:(NSDictionary*)value
{
	if ([value objectForKey:@"id"]) {
		NSNumber *idNumber = (NSNumber*)value[@"id"];
		uint64_t id = [idNumber unsignedLongLongValue];
		if (![_tree has:id]) {
			return false;
		}
		if (![_tree set:id value:value]) {
			return false;
		}
	} else {
		return false;
	}
	return true;
}

- (bool)remove:(uint64_t)id
{
	if ([_tree has:id]) {
		if (![_tree remove:id]) {
			return false;
		}
	}
	return true;
}

- (NSData*)recovery
{
	if (_indexDictionary.count == 0) {
		return [_tree recovery];
	}
	NSMutableData *data = [[NSMutableData alloc] init];
	[data appendData:[_tree recovery]];
	[data appendUInteger:_indexDictionary.count];
	for (NSArray *indexKey in [_indexDictionary keyEnumerator]) {
		DbIndex *index = _indexDictionary[indexKey];
		[data appendString:index.name];
		[data appendData:[index recovery]];
	}
	return data;
}

//- (NSData*)data
//{
//	NSMutableData *data = [[NSMutableData alloc] init];
//	[data appendString:_name];
//	[data appendUInteger:_indexDictionary.count];
//	for (NSArray *indexKey in [_indexDictionary keyEnumerator]) {
//		DbIndex *index = _indexDictionary[indexKey];
//		[data appendString:index.name];
//	}
//	return data;
//}

- (bool)write
{
	if (![_tree write]) {
		return false;
	}
	for (NSArray *indexKey in [_indexDictionary keyEnumerator]) {
		DbIndex *index = _indexDictionary[indexKey];
		if (![index write]) {
			return false;
		}
	}
	return true;
}

@end

@implementation DbIndex

@synthesize name = _name;

@synthesize index = _index;

@synthesize tree = _tree;

- (id)initWithName:(NSString*)name index:(NSArray*)index withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate
{
	if (!(self = [super init])) return nil;
	_name = name;
	_index = index;
	if (!(_tree = [[DbTree alloc] initNamed:name withMemoryDelegate:memoryDelegate withStorageDelegate:storageDelegate])) {
		return nil;
	}
	return self;
}

- (bool)create
{
	_tree.changed = true;
	return true;
}

- (bool)drop
{
	return false;
}

- (NSDictionary*)search:(NSArray*)indexs
{
	return nil;
}

- (bool)insert:(NSDictionary*)value
{
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:value];
	[dic setObject:[NSNumber numberWithUnsignedLongLong:1] forKey:@"id"];
	return true;
}

- (bool)update:(NSArray*)indexs value:(NSDictionary*)value
{
	return false;
}

- (bool)remove:(NSArray*)indexs value:(NSDictionary*)value
{
	return false;
}

- (NSData*)recovery
{
	return [_tree recovery];
}

- (bool)write
{
	[_tree write];
	return true;
}

@end