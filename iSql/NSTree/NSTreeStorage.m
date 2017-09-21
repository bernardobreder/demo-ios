//
//  NSTreeStorage.m
//  iSql
//
//  Created by Bernardo Breder on 14/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "NSTree.h"
#import "NSReaderData.h"
#import "NSTreeStorage.h"

@interface NSTreeStorageEntry : NSObject

@property (nonatomic, strong) NSTree *tree;
@property (nonatomic, strong) NSString *name;

@end

@implementation NSTreeStorageEntry

@synthesize tree = _tree;
@synthesize name = _name;

@end

@interface NSTreeStorage ()

@property (nonatomic, strong) NSMutableDictionary *trees;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *basePath;

@end

@implementation NSTreeStorage

@synthesize trees = _trees;
@synthesize name = _name;
@synthesize path = _path;
@synthesize basePath = _basePath;

+ (void)clear
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSString *dbHome = [NSHomeDirectory() stringByAppendingString:@"/Database/"];
    [fs removeItemAtPath:dbHome error:nil];
    NSArray *files = [fs contentsOfDirectoryAtPath:dbHome error:nil];
    if (files) {
        for (NSInteger n = 0; n < files.count ; n++) {
            NSString *filename = files[n];
            NSString *path = [[NSHomeDirectory() stringByAppendingString:@"/Database/"] stringByAppendingString:filename];
            NSDictionary *attrs = [fs attributesOfItemAtPath:path error:nil];
            NSString *fileType = [attrs valueForKey:NSFileType];
            if (fileType != NSFileTypeDirectory) {
                if ([filename hasSuffix:@".lock"]) {
                    [fs removeItemAtPath:path error:nil];
                }
            }
        }
    }
}

- (id)initWithName:(NSString*)name
{
    if (!(self = [super init])) return nil;
    _name = name;
    _trees = [[NSMutableDictionary alloc] init];
    _basePath = [NSHomeDirectory() stringByAppendingString:@"/Database/"];
    _path = [_basePath stringByAppendingString:name];
    @autoreleasepool {
        NSFileManager *fs = [NSFileManager defaultManager];
        NSString *lockPath = [NSString stringWithFormat:@"%@.lock", _path];
        if ([fs fileExistsAtPath:lockPath]) {
            NSArray *files = [fs contentsOfDirectoryAtPath:_basePath error:nil];
            if (files) {
                for (NSInteger n = 0; n < files.count ; n++) {
                    NSString *filename = files[n];
                    if ([filename hasSuffix:@".backup"]) {
                        NSString *indexBackupPath = [_path stringByAppendingString:filename];
                        NSString *indexPath = [indexBackupPath stringByReplacingOccurrencesOfString:@".backup" withString:@".db"];
                        [fs removeItemAtPath:indexPath error:nil];
                        [fs moveItemAtPath:indexBackupPath toPath:indexPath error:nil];
                    }
                }
            }
            [fs removeItemAtPath:lockPath error:nil];
        } else {
            NSArray *files = [fs contentsOfDirectoryAtPath:_basePath error:nil];
            if (files) {
                for (NSInteger n = 0; n < files.count ; n++) {
                    NSString *filename = files[n];
                    if ([filename hasSuffix:@".backup"]) {
                        NSString *path = [_path stringByAppendingString:filename];
                        [fs removeItemAtPath:path error:nil];
                    }
                }
            }
        }
        NSString *dataPath = [_path stringByAppendingString:@".db"];
        if ([fs fileExistsAtPath:dataPath]) {
            NSData *data = [fs contentsAtPath:dataPath];
            if (!data) {
                return nil;
            }
            NSUInteger offset = 0;
            NSUInteger treeCount = [data readUInteger:&offset];
            for (NSUInteger n = 0; n < treeCount ; n++) {
                NSString *name = [data readString:&offset];
                NSTreeStorageEntry *entry = [[NSTreeStorageEntry alloc] init];
                entry.name = name;
                entry.tree = [[NSTree alloc] init];
                [_trees setValue:entry forKey:name];
            }
        }
        
    }
    return self;
}

- (void)dealloc
{
    [_trees removeAllObjects];
}

- (void)addTree:(NSTree*)tree withName:(NSString*)name
{
    NSTreeStorageEntry *entry = [[NSTreeStorageEntry alloc] init];
    entry.name = name;
    entry.tree = tree;
    [_trees setValue:entry forKey:name];
}

- (NSMutableDictionary*)getInTree:(NSString*)name indexAt:(NSInteger)id
{
    NSTreeStorageEntry *entry = [_trees objectForKey:name];
    if (!entry) {
        return nil;
    }
    NSTree *tree = entry.tree;
    return (NSMutableDictionary*)[tree get:id];
}

- (bool)commit
{
    @autoreleasepool {
        NSFileManager *fs = [NSFileManager defaultManager];
        [fs createDirectoryAtPath:_basePath withIntermediateDirectories:true attributes:nil error:nil];
        NSString *lockPath = [NSString stringWithFormat:@"%@.lock", _path];
        [[[NSMutableData alloc] init] writeToFile:lockPath atomically:false];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        NSMutableArray *indexLockArray = [[NSMutableArray alloc] init];
        NSMutableArray *indexBackupArray = [[NSMutableArray alloc] init];
        for (NSString *key in [_trees keyEnumerator]) {
            NSTreeStorageEntry *entry = _trees[key];
            NSTree *tree = entry.tree;
            NSTreeNode *node = [tree first];
            NSTree *set = [[NSTree alloc] init];
            while (node) {
//                if (node.changed) {
//                    NSInteger key = node.key / 16;
//                    [set add:key  value:nil];
//                }
                node = [node next];
            }
            if (![set isEmpty]) {
                NSMutableData *data = [[NSMutableData alloc] init];
                NSTreeNode *indexNode = [set first];
                while (indexNode) {
                    NSInteger index = indexNode.key;
                    for (NSInteger n = 0; n < 16 ; n++) {
                        NSDictionary *value = (NSDictionary*)[tree get:(index * 16 + n + 1)];
                        if (value) {
                            for (NSString *key in [value keyEnumerator]) {
                                NSObject *object = [value valueForKey:key];
                                if ([object isKindOfClass:[NSNumber class]]) {
                                    NSNumber *number = (NSNumber*)object;
                                    NSInteger intValue = [number integerValue];
                                    unsigned char buffer[5];
                                    buffer[0] = 1;
                                    buffer[1] = (intValue >> 24) & 0xFF;
                                    buffer[2] = (intValue >> 16) & 0xFF;
                                    buffer[3] = (intValue >> 8) & 0xFF;
                                    buffer[4] = (intValue >> 0) & 0xFF;
                                    if (intValue < 0) {
                                        buffer[1] += 0x80;
                                    }
                                    [data appendBytes:buffer length:sizeof(buffer)];
                                } else if ([object isKindOfClass:[object class]]) {
                                    NSString *string = (NSString*)object;
                                    NSInteger length = string.length;
                                    unsigned char buffer[5];
                                    buffer[0] = 5;
                                    buffer[1] = (length >> 24) & 0xFF;
                                    buffer[2] = (length >> 16) & 0xFF;
                                    buffer[3] = (length >> 8) & 0xFF;
                                    buffer[4] = (length >> 0) & 0xFF;
                                    [data appendBytes:buffer length:sizeof(buffer)];
                                    [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
                                }
                            }
                        } else {
                            [data appendBytes:"\0" length:1];
                        }
                    }
                    indexNode = [indexNode next];
                }
                NSString *indexPath = [NSString stringWithFormat:@"%@_%@_%ld.db", _path, key, (long)indexNode.key];
                NSString *indexLockPath = [NSString stringWithFormat:@"%@_%@_%ld.lock", _path, key, (long)indexNode.key];
                NSString *indexBackupPath = [NSString stringWithFormat:@"%@_%@_%ld.backup", _path, key, (long)indexNode.key];
                if (![data writeToFile:indexLockPath atomically:false]) {
                    return false;
                }
                if ([fs fileExistsAtPath:indexPath]) {
                    if (![fs copyItemAtPath:indexPath toPath:indexBackupPath error:nil]) {
                        return false;
                    }
                }
                [indexArray addObject:indexPath];
                [indexLockArray addObject:indexLockPath];
                [indexBackupArray addObject:indexBackupPath];
            }
            [set clear];
        }
        {
            NSString *indexPath = [NSString stringWithFormat:@"%@.db", _path];
            NSString *indexLockPath = [NSString stringWithFormat:@"%@.lock", _path];
            NSString *indexBackupPath = [NSString stringWithFormat:@"%@.backup", _path];
            NSMutableData *data = [[NSMutableData alloc] init];
            unsigned char buffer[4];
            NSUInteger treeCount = _trees.count;
            buffer[0] = (treeCount >> 24) & 0xFF;
            buffer[1] = (treeCount >> 16) & 0xFF;
            buffer[2] = (treeCount >> 8) & 0xFF;
            buffer[3] = (treeCount >> 0) & 0xFF;
            [data appendBytes:buffer length:sizeof(buffer)];
            for (NSString *key in [_trees keyEnumerator]) {
                NSUInteger nameLength = key.length;
                buffer[0] = (nameLength >> 24) & 0xFF;
                buffer[1] = (nameLength >> 16) & 0xFF;
                buffer[2] = (nameLength >> 8) & 0xFF;
                buffer[3] = (nameLength >> 0) & 0xFF;
                [data appendBytes:buffer length:sizeof(buffer)];
                [data appendData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if (![data writeToFile:indexLockPath atomically:false]) {
                return false;
            }
            if ([fs fileExistsAtPath:indexPath]) {
                if (![fs copyItemAtPath:indexPath toPath:indexBackupPath error:nil]) {
                    return false;
                }
            }
            [indexArray addObject:indexPath];
            [indexLockArray addObject:indexLockPath];
            [indexBackupArray addObject:indexBackupPath];
        }
        for (NSInteger n = 0; n < indexArray.count ; n++) {
            NSString *indexPath = [indexArray objectAtIndex:n];
            NSString *indexLockPath = [indexLockArray objectAtIndex:n];
            if (![fs moveItemAtPath:indexLockPath toPath:indexPath error:nil]) {
                return false;
            }
        }
        [fs removeItemAtPath:lockPath error:nil];
        for (NSInteger n = 0; n < indexArray.count ; n++) {
            NSString *indexBackupPath = [indexBackupArray objectAtIndex:n];
            if ([fs fileExistsAtPath:indexBackupPath]) {
                if (![fs removeItemAtPath:indexBackupPath error:nil]) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (void)rollback
{
    
}

@end