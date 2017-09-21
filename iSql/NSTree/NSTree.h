//
//  NSTree.h
//  iSql
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@class NSTreeNode;

@interface NSTree : NSObject

@property (nonatomic, strong) NSTreeNode* root;
@property (nonatomic, assign) NSUInteger size;

- (bool)add:(NSInteger)key value:(NSObject*)value;

- (NSObject*)get:(NSInteger)key;

- (bool)set:(NSInteger)key value:(NSObject*)value;

- (bool)remove:(NSInteger)key;

- (bool)isEmpty;

- (void)clear;

- (NSTreeNode*)first;

- (NSTreeNode*)getNode:(NSInteger)key;

@end

@interface NSTreeNode : NSObject

@property (nonatomic, assign) NSInteger key;
@property (nonatomic, strong) NSObject* value;
@property (nonatomic, strong) NSTreeNode* left;
@property (nonatomic, strong) NSTreeNode* right;
@property (nonatomic, strong) NSTreeNode* parent;
@property (nonatomic, assign) bool black;

- (NSTreeNode*)next;

- (void)clear;

@end