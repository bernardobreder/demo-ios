//
//  DbIndexTree.h
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface DbIndexTreeNode : NSObject

@property (nonatomic, assign) uint64_t *value;

@property (nonatomic, strong) DbIndexTreeNode* left;

@property (nonatomic, strong) DbIndexTreeNode* right;

@property (nonatomic, strong) DbIndexTreeNode* parent;

@property (nonatomic, assign) bool black;

- (void)swapKey:(DbIndexTreeNode*)node;

- (int64_t)compare:(DbIndexTreeNode*)node;

- (DbIndexTreeNode*)next;

- (void)clear;

@end

@interface Db1IndexTreeNode : DbIndexTreeNode

@property (nonatomic, assign) uint64_t key1;

@end

@interface DbIndexTree : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) bool changed;

@property (nonatomic, assign, readonly) uint64_t size;

- (id)init:(NSString*)name;

- (NSData*)recoveryData;

- (NSData*)structureData;

- (NSData*)nodeData:(DbIndexTreeNode*)node;

@end

@interface IdArray : NSObject

@property (nonatomic, assign, readonly) NSInteger count;

- (uint64_t)get:(NSInteger)index;

@end

@interface Db1IndexTree : DbIndexTree

- (IdArray*)get:(uint64_t)key;

- (bool)add:(uint64_t)key value:(uint64_t)value;

- (bool)has:(uint64_t)key value:(uint64_t)value;

- (bool)remove:(uint64_t)key;

@end
