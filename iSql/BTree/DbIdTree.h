//
//  BTree.h
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#define DB_ID_TREE_ORDER 3

@interface DbIdTreeNode : NSObject

@end

@protocol DbIdTreeStorageDelegate <NSObject>

@required

- (bool)hasDbIdTreeNodeData:(NSString*)name id:(uint64_t)id;

- (NSData*)readDbIdTreeNodeData:(NSString*)name id:(uint64_t)id cached:(bool)cached;

- (bool)writeDbIdTreeNodeData:(NSString*)name id:(uint64_t)id data:(NSData*)data;

- (bool)removeDbIdTreeNodeData:(NSString*)name id:(uint64_t)id;

- (bool)hasDbIdTreeRecoveryData;

- (NSData*)readDbIdTreeRecoveryData;

- (bool)writeDbIdTreeRecoveryData:(NSData*)data;

- (bool)removeDbIdTreeRecoveryData;

- (bool)hasDbIdTreeStructureData:(NSString*)name;

- (NSData*)readDbIdTreeStructureData:(NSString*)name;

- (bool)writeDbIdTreeStructureData:(NSString*)name data:(NSData*)data;

- (bool)removeDbIdTreeStructureData:(NSString*)name;

@optional

@end

@interface DbIdTree : NSObject

@property (nonatomic, weak, readonly) id<DbIdTreeStorageDelegate> storageDelegate;

@property (nonatomic, assign) bool changed;

@property (nonatomic, assign) uint64_t count;

- (id)initNamed:(NSString*)name withStorageDelegate:(id<DbIdTreeStorageDelegate>)storageDelegate;

- (NSObject*)get:(uint64_t)key;

- (bool)add:(uint64_t)key value:(NSObject*)value;

- (bool)has:(uint64_t)key;

- (bool)set:(uint64_t)key value:(NSObject*)value;

- (bool)remove:(uint64_t)key;

- (NSString*)string;

- (NSData*)recovery;

- (bool)write;

@end
