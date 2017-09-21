//
//  DbConnection.m
//  iSql
//
//  Created by Bernardo Breder on 25/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "DbConnection.h"

@interface DbConnection ()

@property (nonatomic, strong) NSMutableDictionary *tables;

@property (nonatomic, weak) id<DbTreeMemoryDelegate> memoryDelegate;

@property (nonatomic, weak) id<DbTreeStorageDelegate> storageDelegate;

@end

@implementation DbConnection

@synthesize tables = _tables;

@synthesize memoryDelegate = _memoryDelegate;

@synthesize storageDelegate = _storageDelegate;

- (id)initWithMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate
{
	if (!(self = [super init])) return nil;
	_memoryDelegate = memoryDelegate;
	_storageDelegate = storageDelegate;
	_tables = [[NSMutableDictionary alloc] init];
	return self;
}

- (DbTable*)table:(NSString*)name
{
    DbTable *table = _tables[name];
    if (!table) {
        table = [[DbTable alloc] initWithName:name connection:self withMemoryDelegate:_memoryDelegate withStorageDelegate:_storageDelegate];
        _tables[name] = table;
    }
    return table;
}

- (bool)commit
{
	if (!_storageDelegate) {
		return false;
	}
	{
		NSMutableData *data = [[NSMutableData alloc] init];
		for (NSString *name in [_tables keyEnumerator]) {
			DbTable *table = _tables[name];
			NSData *recoveryData = [table recovery];
			if (!recoveryData) {
				return false;
			}
			[data appendData:recoveryData];
		}
		[data appendUByte:0xFF];
		if (![_storageDelegate writeRecoveryData:data]) {
			return false;
		}
	}
	{
		for (NSString *name in [_tables keyEnumerator]) {
			DbTable *table = _tables[name];
			if (![table write]) {
				return false;
			}
		}
	}
	if (![_storageDelegate removeRecoveryData]) {
		return false;
	}
    [_tables removeAllObjects];
    return true;
}

- (void)rollback
{
    [_tables removeAllObjects];
}

@end
