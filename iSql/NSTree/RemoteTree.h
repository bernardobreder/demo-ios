//
//  NSRemoteTree.h
//  iSql
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@class NSTreeNode;
@class NSRemoteTreeNode;

@interface NSRemoteTree : NSObject

@property (nonatomic, strong) NSRemoteTreeNode* root;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) bool changed;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSTree *cache;

- (id)initWithPath:(NSString*)path;

- (bool)add:(NSInteger)key value:(NSObject*)value;

- (NSObject*)get:(NSInteger)key;

- (bool)set:(NSInteger)key value:(NSObject*)value;

- (bool)remove:(NSInteger)key;

- (bool)isEmpty;

- (void)clear;

- (void)unmarkChanged;

- (NSRemoteTreeNode*)first;

- (NSRemoteTree*)writeTempFile;

- (NSRemoteTree*)writeBackupFile;

- (NSRemoteTree*)writeTempToDbFile;

- (NSRemoteTree*)deleteBackupFile;

- (NSRemoteTree*)clearTempBackupFiles;

@end

@interface NSRemoteTreeNode : NSObject

@property (nonatomic, assign) NSInteger key;
@property (nonatomic, assign) NSInteger leftKey;
@property (nonatomic, assign) NSInteger rightKey;
@property (nonatomic, strong) NSObject* value;
@property (nonatomic, strong) NSRemoteTreeNode* left;
@property (nonatomic, strong) NSRemoteTreeNode* right;
@property (nonatomic, strong) NSRemoteTreeNode* parent;
@property (nonatomic, assign) bool black;
@property (nonatomic, assign) bool changed;

- (NSRemoteTreeNode*)next:(NSRemoteTree*)tree;

- (void)clear;

- (void)unmarkChanged;

@end