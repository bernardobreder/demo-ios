//
//  NSRemoteTree.m
//  iSql
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "RemoteTree.h"

@implementation NSRemoteTree

#define NODE_PER_FILE 1024

@synthesize root = _root;
@synthesize size = _size;
@synthesize changed = _changed;
@synthesize path = _path;
@synthesize cache = _cache;

- (id)initWithPath:(NSString*)path
{
    if (!(self = [super init])) return nil;
    _path = path;
    _cache = [[NSTree alloc] init];
    NSFileManager *fs = [NSFileManager defaultManager];
    NSString *treePath = [NSString stringWithFormat:@"%@.db", _path];
    NSString *dirPath = [treePath stringByDeletingLastPathComponent];
    NSArray *files = [fs contentsOfDirectoryAtPath:dirPath error:nil];
    if (files) {
        for (NSUInteger n = 0 ; n < files.count ; n++) {
            NSString *file = files[n];
            NSString *path = [[dirPath stringByAppendingString:@"/"] stringByAppendingString:file];
            if ([path hasPrefix:_path]) {
                if ([file hasSuffix:@".backup"]) {
                    NSString *backupFile = [[dirPath stringByAppendingString:@"/"] stringByAppendingString:file];
                    NSString *dbFile = [[dirPath stringByAppendingString:@"/"] stringByAppendingString:[file stringByReplacingOccurrencesOfString:@".backup" withString:@".db"]];
                    [fs removeItemAtPath:dbFile error:nil];
                    if (![fs moveItemAtPath:backupFile toPath:dbFile error:nil]) {
                        return nil;
                    }
                } else if ([file hasSuffix:@".temp"]) {
                    [fs removeItemAtPath:path error:nil];
                }
            }
        }
    }
    if ([fs fileExistsAtPath:treePath]) {
        NSData *data = [fs contentsAtPath:treePath];
        NSUInteger offset = 0;
        NSInteger nodesPerFile = [data readUInteger:&offset];
        NSInteger rootKey = [data readInteger:&offset];
        _root = [self readTreeNode:rootKey];
    }
    return self;
}

- (NSRemoteTreeNode*)readTreeNode:(NSInteger)id
{
    NSInteger index = (id-1) / NODE_PER_FILE;
    NSMutableArray *array = (NSMutableArray*)[_cache get:index];
    if (!array) {
        NSFileManager *fs = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@$%ld.db", _path, (long)index];
        if (![fs fileExistsAtPath:path]) {
            return nil;
        }
        array = [[NSMutableArray alloc] initWithCapacity:NODE_PER_FILE];
        NSData *data = [fs contentsAtPath:path];
        NSUInteger offset = 0;
        NSUInteger size = [data readUInteger:&offset];
        for (NSUInteger n = 0 ; n < size ; n++) {
            if ([data isNull:offset]) {
                [array addObject:[NSNull null]];
            } else {
                NSRemoteTreeNode* node = [[NSRemoteTreeNode alloc] init];
                node.key = [data readInteger:&offset];
                node.leftKey = [data readInteger:&offset];
                node.rightKey = [data readInteger:&offset];
                node.black = [data readBoolean:&offset];
                NSUInteger count = [data readUInteger:&offset];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:count];
                for (NSUInteger n = 0 ; n < count ; n++) {
                    NSObject *key = [data readObject:&offset];
                    NSObject *value = [data readObject:&offset];
                    [dic setObject:value forKey:key];
                }
                node.value = dic;
                [array addObject:node];
            }
        }
        [_cache add:index value:array];
    }
    NSInteger cell = (id-1) - index * NODE_PER_FILE;
    return array[cell];
}

- (NSMutableArray*)_cacheAt:(NSInteger)key
{
    NSInteger index = (key-1) / NODE_PER_FILE;
    NSMutableArray *array = (NSMutableArray*)[_cache get:index];
    if (!array) {
        array = [[NSMutableArray alloc] initWithCapacity:NODE_PER_FILE];
        for (NSUInteger n = 0 ; n < NODE_PER_FILE ; n++) {
            [array addObject:[NSNull null]];
        }
        [_cache add:index value:array];
    }
    return array;
}

- (bool)writeTreeNode:(NSInteger)id
{
    return false;
}

- (bool)add:(NSInteger)key value:(NSObject*)value
{
    NSRemoteTreeNode* aux = _root;
    if (!aux) {
        NSRemoteTreeNode* entry = [[NSRemoteTreeNode alloc] init];
        if (!entry) {
            return false;
        }
        entry.leftKey = 0;
        entry.rightKey = 0;
        entry.key = key;
        entry.value = value;
        entry.changed = true;
        _root = entry;
        _size++;
        _changed = true;
        [self _cacheAt:key][(key-1) - ((key-1) / NODE_PER_FILE) * NODE_PER_FILE] = entry;
        return true;
    }
    NSRemoteTreeNode* parent;
    NSInteger cmp;
    do {
        parent = aux;
        cmp = key - aux.key;
        if (cmp < 0) {
            aux = aux.left || !aux.leftKey ? aux.left : [self readTreeNode:aux.leftKey];
        } else if (cmp > 0) {
            aux = aux.right || !aux.rightKey ? aux.right : [self readTreeNode:aux.rightKey];
        } else {
            aux.value = value;
            _changed = true;
            aux.changed = true;
            return true;
        }
    } while (aux);
    NSRemoteTreeNode* entry = [[NSRemoteTreeNode alloc] init];
    if (!entry) {
        return false;
    }
    entry.key = key;
    entry.value = value;
    entry.parent = parent;
    entry.changed = true;
    [self _cacheAt:key][(key-1) - ((key-1) / NODE_PER_FILE) * NODE_PER_FILE] = entry;
    if (cmp < 0) {
        parent.left = entry;
        parent.leftKey = entry.key;
    } else {
        parent.right = entry;
        parent.rightKey = entry.key;
    }
    parent.changed = true;
    [self fixAfterInsertion:entry];
    _size++;
    _changed = true;
    return true;
}

- (NSObject*)get:(NSInteger)key
{
    NSRemoteTreeNode *p = [self getNode:key];
    return !p ? 0 : p.value;
}

- (bool)set:(NSInteger)key value:(NSObject*)value
{
    NSRemoteTreeNode* p = [self getNode:key];
	if (p) {
        p.value = value;
        p.changed = true;
        _changed = true;
        return true;
	}
    return false;
}

- (bool)remove:(NSInteger)key
{
    NSRemoteTreeNode* p = [self getNode:key];
	if (p) {
        [self removeNode:p];
        _changed = true;
        return true;
	}
    return false;
}

- (NSRemoteTreeNode*)first
{
    NSRemoteTreeNode* p = _root;
    while (p.left) {
        p = p.left;
    }
    return p;
}

- (bool)isEmpty
{
    return _size == 0;
}

- (void)clear
{
    [_root clear];
    [_cache clear];
    _root = nil;
    _size = 0;
    _changed = true;
    
}

- (void)unmarkChanged
{
    if (_root) {
        [_root unmarkChanged];
    }
    if (_changed) {
        _changed = false;
    }
}

- (NSRemoteTree*)writeTempFile
{
    NSTreeNode *node = [_cache first];
    while (node) {
        NSInteger index = node.key;
        NSArray *array = (NSArray*)node.value;
        bool changed = false;
        for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
            if (array[n] != [NSNull null]) {
                NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                if (remoteNode.changed) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            NSMutableData *data = [[NSMutableData alloc] init];
            [data appendUInteger:NODE_PER_FILE];
            for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
                if (array[n] == [NSNull null]) {
                    [data appendNull];
                } else {
                    NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                    [data appendInteger:remoteNode.key];
                    [data appendInteger:remoteNode.leftKey];
                    [data appendInteger:remoteNode.rightKey];
                    [data appendBoolean:remoteNode.black];
                    NSDictionary *dic = (NSDictionary*)remoteNode.value;
                    [data appendUInteger:dic.count];
                    [dic enumerateKeysAndObjectsUsingBlock:^(id<NSObject> key, id<NSObject> value, BOOL *stop) {
                        [data appendNSObject:key];
                        [data appendNSObject:value];
                    }];
                }
            }
            NSString *path = [NSString stringWithFormat:@"%@$%d.temp", _path, index];
            [data writeToFile:path atomically:false];
        }
        node = [node next];
    }
    if (self.root && self.root.changed) {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendUInteger:NODE_PER_FILE];
        [data appendInteger:self.root.key];
        NSString *path = [NSString stringWithFormat:@"%@.temp", _path];
        [data writeToFile:path atomically:false];
    }
    return self;
}

- (NSRemoteTree*)writeBackupFile
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSTreeNode *node = [_cache first];
    while (node) {
        NSInteger index = node.key;
        NSArray *array = (NSArray*)node.value;
        bool changed = false;
        for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
            if (array[n] != [NSNull null]) {
                NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                if (remoteNode.changed) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            NSString *dbPath = [NSString stringWithFormat:@"%@$%d.db", _path, index];
            NSString *backupPath = [NSString stringWithFormat:@"%@$%d.backup", _path, index];
            [fs copyItemAtPath:dbPath toPath:backupPath error:nil];
        }
        node = [node next];
    }
    if (self.root && self.root.changed) {
        NSString *dbPath = [NSString stringWithFormat:@"%@.db", _path];
        NSString *backupPath = [NSString stringWithFormat:@"%@.backup", _path];
        [fs copyItemAtPath:dbPath toPath:backupPath error:nil];
    }
    return self;
}

- (NSRemoteTree*)writeTempToDbFile
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSTreeNode *node = [_cache first];
    while (node) {
        NSInteger index = node.key;
        NSArray *array = (NSArray*)node.value;
        bool changed = false;
        for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
            if (array[n] != [NSNull null]) {
                NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                if (remoteNode.changed) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            NSString *tempPath = [NSString stringWithFormat:@"%@$%d.temp", _path, index];
            NSString *dbPath = [NSString stringWithFormat:@"%@$%d.db", _path, index];
            [fs removeItemAtPath:dbPath error:nil];
            [fs moveItemAtPath:tempPath toPath:dbPath error:nil];
        }
        node = [node next];
    }
    if (self.root && self.root.changed) {
        NSString *tempPath = [NSString stringWithFormat:@"%@.temp", _path];
        NSString *dbPath = [NSString stringWithFormat:@"%@.db", _path];
        [fs removeItemAtPath:dbPath error:nil];
        [fs moveItemAtPath:tempPath toPath:dbPath error:nil];
    }
    return self;
}

- (NSRemoteTree*)deleteBackupFile
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSTreeNode *node = [_cache first];
    while (node) {
        NSInteger index = node.key;
        NSArray *array = (NSArray*)node.value;
        bool changed = false;
        for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
            if (array[n] != [NSNull null]) {
                NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                if (remoteNode.changed) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            NSString *backupPath = [NSString stringWithFormat:@"%@$%d.backup", _path, index];
            [fs removeItemAtPath:backupPath error:nil];
        }
        node = [node next];
    }
    if (self.root && self.root.changed) {
        NSString *backupPath = [NSString stringWithFormat:@"%@.backup", _path];
        [fs removeItemAtPath:backupPath error:nil];
    }
    return self;
}

- (NSRemoteTree*)clearTempBackupFiles
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSTreeNode *node = [_cache first];
    while (node) {
        NSInteger index = node.key;
        NSArray *array = (NSArray*)node.value;
        bool changed = false;
        for (NSUInteger n = 0; n < NODE_PER_FILE ; n++) {
            if (array[n] != [NSNull null]) {
                NSRemoteTreeNode *remoteNode = (NSRemoteTreeNode*)array[n];
                if (remoteNode.changed) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            NSString *tempPath = [NSString stringWithFormat:@"%@$%d.temp", _path, index];
            NSString *backupPath = [NSString stringWithFormat:@"%@$%d.backup", _path, index];
            [fs removeItemAtPath:tempPath error:nil];
            [fs removeItemAtPath:backupPath error:nil];
        }
        node = [node next];
    }
    return self;
}

#define b_treemap_entry_red false
#define b_treemap_entry_black true
#define b_treemap_entry_set_color(p,c) if (p) { p.black = c; p.changed = true; }
#define b_treemap_entry_color(p) (!p ? true : p.black)
#define b_treemap_entry_right(p) (!p ? 0: p.right)
#define b_treemap_entry_left(p) (!p ? 0: p.left)
#define b_treemap_entry_parent(p) (!p ? 0: p.parent)

- (NSRemoteTreeNode*)getNode:(NSInteger)key
{
    NSRemoteTreeNode *p = _root;
    while (p) {
        NSInteger cmp = key - p.key;
        if (cmp < 0) {
            p = p.left || !p.leftKey ? p.left : [self readTreeNode:p.leftKey];
        } else if (cmp > 0) {
            p = p.right || !p.rightKey ? p.right : [self readTreeNode:p.rightKey];
        } else {
            return p;
        }
    }
    return 0;
}

- (bool)fixAfterInsertion:(NSRemoteTreeNode*)x
{
    x.black = b_treemap_entry_red;
	while (x && x != _root && x.parent.black == b_treemap_entry_red) {
		if (b_treemap_entry_parent(x) == b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)))) {
			NSRemoteTreeNode* y = b_treemap_entry_right(b_treemap_entry_parent(b_treemap_entry_parent(x)));
			if (b_treemap_entry_color(y) == b_treemap_entry_red) {
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color(y, b_treemap_entry_black);
				b_treemap_entry_set_color( b_treemap_entry_parent(b_treemap_entry_parent(x)), b_treemap_entry_red);
				x = b_treemap_entry_parent(b_treemap_entry_parent(x));
			} else {
				if (x == b_treemap_entry_right(b_treemap_entry_parent(x))) {
					x = b_treemap_entry_parent(x);
					[self rotateLeft:x];
				}
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color( b_treemap_entry_parent(b_treemap_entry_parent(x)), b_treemap_entry_red);
				[self rotateRight:b_treemap_entry_parent(b_treemap_entry_parent(x))];
			}
		} else {
			NSRemoteTreeNode* y = b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)));
			if (b_treemap_entry_color(y) == b_treemap_entry_red) {
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color(y, b_treemap_entry_black);
				b_treemap_entry_set_color( b_treemap_entry_parent(b_treemap_entry_parent(x)), b_treemap_entry_red);
				x = b_treemap_entry_parent(b_treemap_entry_parent(x));
			} else {
				if (x == b_treemap_entry_left(b_treemap_entry_parent(x))) {
					x = b_treemap_entry_parent(x);
					[self rotateRight:x];
				}
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color( b_treemap_entry_parent(b_treemap_entry_parent(x)), b_treemap_entry_red);
				[self rotateLeft:b_treemap_entry_parent(b_treemap_entry_parent(x))];
			}
		}
	}
	_root.black = b_treemap_entry_black;
    return true;
}

- (void)fixAfterDeletion:(NSRemoteTreeNode*)x
{
	while (x != _root && b_treemap_entry_color(x) == b_treemap_entry_black) {
		if (x == b_treemap_entry_left(b_treemap_entry_parent(x))) {
			NSRemoteTreeNode* sib = b_treemap_entry_right(b_treemap_entry_parent(x));
			if (b_treemap_entry_color(sib) == b_treemap_entry_red) {
				b_treemap_entry_set_color(sib, b_treemap_entry_black);
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_red);
				[self rotateLeft:b_treemap_entry_parent(x)];
				sib = b_treemap_entry_right(b_treemap_entry_parent(x));
			}
			if (b_treemap_entry_color(b_treemap_entry_left(sib)) == b_treemap_entry_black && b_treemap_entry_color(b_treemap_entry_right(sib)) == b_treemap_entry_black) {
				b_treemap_entry_set_color(sib, b_treemap_entry_red);
				x = b_treemap_entry_parent(x);
			} else {
				if (b_treemap_entry_color(b_treemap_entry_right(sib)) == b_treemap_entry_black) {
					b_treemap_entry_set_color(b_treemap_entry_left(sib), b_treemap_entry_black);
					b_treemap_entry_set_color(sib, b_treemap_entry_red);
                    [self rotateRight:sib];
					sib = b_treemap_entry_right(b_treemap_entry_parent(x));
				}
				b_treemap_entry_set_color(sib, b_treemap_entry_color(b_treemap_entry_parent(x)));
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color(b_treemap_entry_right(sib), b_treemap_entry_black);
                [self rotateLeft:b_treemap_entry_parent(x)];
				x = _root;
			}
		} else {
			NSRemoteTreeNode* sib = b_treemap_entry_left(b_treemap_entry_parent(x));
			if (b_treemap_entry_color(sib) == b_treemap_entry_red) {
				b_treemap_entry_set_color(sib, b_treemap_entry_black);
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_red);
                [self rotateRight:b_treemap_entry_parent(x)];
				sib = b_treemap_entry_left(b_treemap_entry_parent(x));
			}
			if (b_treemap_entry_color(b_treemap_entry_right(sib)) == b_treemap_entry_black && b_treemap_entry_color(b_treemap_entry_left(sib)) == b_treemap_entry_black) {
				b_treemap_entry_set_color(sib, b_treemap_entry_red);
				x = b_treemap_entry_parent(x);
			} else {
				if (b_treemap_entry_color(b_treemap_entry_left(sib)) == b_treemap_entry_black) {
					b_treemap_entry_set_color(b_treemap_entry_right(sib), b_treemap_entry_black);
					b_treemap_entry_set_color(sib, b_treemap_entry_red);
                    [self rotateLeft:sib];
					sib = b_treemap_entry_left(b_treemap_entry_parent(x));
				}
				b_treemap_entry_set_color(sib, b_treemap_entry_color(b_treemap_entry_parent(x)));
				b_treemap_entry_set_color(b_treemap_entry_parent(x), b_treemap_entry_black);
				b_treemap_entry_set_color(b_treemap_entry_left(sib), b_treemap_entry_black);
                [self rotateRight:b_treemap_entry_parent(x)];
				x = _root;
			}
		}
	}
	b_treemap_entry_set_color(x, b_treemap_entry_black);
}

- (void)removeNode:(NSRemoteTreeNode*)p
{
	_size--;
	if (p.left && p.right) {
		NSRemoteTreeNode* s = [p next:self];
		p.key = s.key;
		p.value = s.value;
        p.changed = true;
		p = s;
	}
	NSRemoteTreeNode* replacement = p.left ? p.left : p.right;
	if (replacement) {
        if (replacement.parent) {
            replacement.parent.changed = true;
        }
		replacement.parent = p.parent;
		if (!p.parent) {
			_root = replacement;
		} else if (p == p.parent.left) {
			p.parent.left = replacement;
            p.parent.leftKey = replacement.key;
            p.parent.changed = true;
		} else {
			p.parent.right = replacement;
            p.parent.rightKey = replacement.key;
            p.parent.changed = true;
		}
		p.left = p.right = p.parent = nil;
        p.leftKey = p.rightKey = -1;
        p.changed = true;
		if (p.black == b_treemap_entry_black) {
			[self fixAfterInsertion:replacement];
		}
	} else if (!p.parent) {
		_root = nil;
	} else {
		if (p.black == b_treemap_entry_black) {
			[self fixAfterInsertion:p];
		}
		if (p.parent) {
			if (p == p.parent.left) {
				p.parent.left = nil;
                p.parent.leftKey = -1;
                p.parent.changed = true;
			} else if (p == p.parent.right) {
				p.parent.right = nil;
                p.parent.rightKey = -1;
                p.parent.changed = true;
			}
			p.parent = nil;
		}
	}
}

- (void)rotateLeft:(NSRemoteTreeNode*)p
{
    if (p) {
        NSRemoteTreeNode* r = p.right;
		p.right = r.left;
        p.rightKey = r.leftKey;
        p.changed = true;
		if (r.left) {
			r.left.parent = p;
		}
		r.parent = p.parent;
        if (!p.parent) {
			_root = r;
		} else if (p.parent.left == p) {
			p.parent.left = r;
            p.parent.leftKey = r.key;
        } else {
			p.parent.right = r;
            p.parent.rightKey = r.key;
		}
        if (p.parent.parent) {
            p.parent.parent.changed = true;
        }
		r.left = p;
        r.leftKey = p.key;
		r.parent.changed = true;
		p.parent = r;
	}
}

- (void)rotateRight:(NSRemoteTreeNode*)p
{
    if (p) {
		NSRemoteTreeNode* l = p.left;
		p.left = l.right;
        p.leftKey = l.rightKey;
        p.changed = true;
		if (l.right) {
			l.right.parent = p;
		}
		l.parent = p.parent;
		if (!p.parent) {
			_root = l;
		} else if (p.parent.right == p) {
			p.parent.right = l;
            p.parent.rightKey = l.key;
		} else {
			p.parent.left = l;
            p.parent.leftKey = l.key;
		}
        if (p.parent.parent) {
            p.parent.parent.changed = true;
        }
		l.right = p;
        l.rightKey = p.key;
        l.changed = true;
		p.parent = l;
	}
}

@end

@implementation NSRemoteTreeNode

@synthesize key = _key;
@synthesize leftKey = _leftKey;
@synthesize rightKey = _rightKey;
@synthesize value = _value;
@synthesize left = _left;
@synthesize right = _right;
@synthesize parent = _parent;
@synthesize black = _black;
@synthesize changed = _changed;

- (NSRemoteTreeNode*)next:(NSRemoteTree*)tree
{
    register NSRemoteTreeNode* p;
    NSRemoteTreeNode *rightNode = _right ? _right : [tree readTreeNode:_rightKey];
    if (rightNode) {
		p = rightNode;
        for (;;) {
            NSRemoteTreeNode *leftNode = p.left ? p.left : [tree readTreeNode:p.leftKey];
            if (!leftNode) {
                break;
            }
            p = leftNode;
        }
		return p;
	} else {
		p = _parent;
		NSRemoteTreeNode* ch = self;
        for (;;) {
            if (!p) {
                break;
            }
            NSRemoteTreeNode *rightNode = p.right ? p.right : [tree readTreeNode:p.rightKey];
            if (ch.key != rightNode.key) {
                break;
            }
            ch = p;
			p = p.parent;
        }
		return p;
	}
}

- (void)clear
{
    _value = nil;
    [_left clear];
    [_right clear];
    _left = nil;
    _right = nil;
    _parent = nil;
}

- (void)unmarkChanged
{
    if (_changed) {
        _changed = false;
    }
    if (_left) {
        [_left unmarkChanged];
    }
    if (_right) {
        [_right unmarkChanged];
    }
}

@end