//
//  DbConnection.h
//  iSql
//
//  Created by Bernardo Breder on 25/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@class DbTable;
@class DbConnection;

@protocol DbConnectionStorageDecorator <NSObject>

@optional

- (bool)writeRecoveryData:(NSData*)data;

- (bool)hasRecoveryData;

- (NSData*)readRecoveryData;

- (bool)removeRecoveryData;

@end

@interface DbConnection : NSObject

- (id)initWithMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate;

- (DbTable*)table:(NSString*)name;

- (bool)commit;

- (void)rollback;

@end
