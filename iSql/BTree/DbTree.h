//
//  BTree.h
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#define DBTREE_ORDER 20

@interface DbTreeNode : NSObject

@end

@protocol DbTreeNodeDelegate <NSObject>

- (DbTreeNode*)create;

- (int)compare:(DbTreeNode*)node with:(DbTreeNode*)other;

@end

@protocol DbTreeMemoryDelegate <NSObject>

@optional

- (void)checkPoint:(DbTreeNode*)node;

- (DbTreeNode*)allocNode;

- (void)freeNode:(DbTreeNode*)node;

- (NSObject*)allocValue:(NSUInteger)size;

- (void)freeValue:(NSObject*)value;

@end

@protocol DbTreeStorageDelegate <NSObject>

@required

- (bool)hasNodeData:(NSString*)name id:(uint64_t)id;

- (NSData*)readNodeData:(NSString*)name id:(uint64_t)id cached:(bool)cached;

- (bool)writeNodeData:(NSString*)name id:(uint64_t)id data:(NSData*)data;

- (bool)removeNodeData:(NSString*)name id:(uint64_t)id;

- (bool)hasRecoveryData;

- (NSData*)readRecoveryData;

- (bool)writeRecoveryData:(NSData*)data;

- (bool)removeRecoveryData;

- (bool)hasStructureData:(NSString*)name;

- (NSData*)readStructureData:(NSString*)name;

- (bool)writeStructureData:(NSString*)name data:(NSData*)data;

- (bool)removeStructureData:(NSString*)name;

@optional

@end

@interface DbTree : NSObject

@property (nonatomic, weak, readonly) id<DbTreeMemoryDelegate> memoryDelegate;

@property (nonatomic, weak, readonly) id<DbTreeStorageDelegate> storageDelegate;

@property (nonatomic, assign) bool changed;

@property (nonatomic, assign) uint64_t count;

- (id)initNamed:(NSString*)name withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate;

- (NSObject*)get:(uint64_t)key;

- (NSObject*)get:(uint64_t)key identify:(NSArray*)identify;

- (bool)add:(uint64_t)key value:(NSObject*)value;

- (bool)add:(uint64_t)key identify:(NSArray*)identify value:(NSObject*)value;

- (bool)has:(uint64_t)key;

- (bool)has:(uint64_t)key identify:(NSArray*)identify;

- (bool)set:(uint64_t)key value:(NSObject*)value;

- (bool)set:(uint64_t)key identify:(NSArray*)identify value:(NSObject*)value;

- (bool)remove:(uint64_t)key;

- (NSString*)string;

- (NSData*)recovery;

- (bool)write;

@end
