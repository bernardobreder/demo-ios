//
//  DbTable.h
//  iSql
//
//  Created by Bernardo Breder on 25/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@class DbConnection;
@class DbIndex;
@class DbTable;

@protocol DbTableStorageDelegate <NSObject>

@required

//- (bool)dbtableStorage:(DbTable*)table hasRecoveryData;

//- (NSData*)dbtableStorage:(DbTable*)table readRecoveryData;

- (bool)dbtableStorage:(DbTable*)table writeRecoveryData:(NSData*)data;

//- (bool)dbtableStorage:(DbTable*)table removeRecoveryData;

- (bool)dbtableStorage:(DbTable*)table hasStructureData:(NSString*)name;

- (NSData*)dbtableStorage:(DbTable*)table readStructureData:(NSString*)name;

- (bool)dbtableStorage:(DbTable*)table writeStructureData:(NSString*)name data:(NSData*)data;

- (bool)dbtableStorage:(DbTable*)table removeStructureData:(NSString*)name;

@end

@interface DbIndex : NSObject

- (id)initWithName:(NSString*)name index:(NSArray*)index withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate;

- (bool)create;

- (bool)drop;

- (NSDictionary*)search:(NSArray*)indexs;

- (bool)update:(NSArray*)indexs value:(NSDictionary*)value;

- (bool)remove:(NSArray*)indexs value:(NSDictionary*)value;

- (NSData*)recovery;

- (bool)write;

@end

@interface DbTable : NSObject

- (id)initWithName:(NSString*)name connection:(DbConnection*)connection withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate;

- (bool)create;

- (bool)drop;

//- (NSArray*)indexs;

- (DbIndex*)index:(NSArray*)indexs;

- (NSDictionary*)search:(uint64_t)id;

- (bool)insert:(NSDictionary*)value;

- (bool)update:(NSDictionary*)value;

- (bool)remove:(uint64_t)id;

- (NSData*)recovery;

- (bool)write;

@end
