//
//  BTree.m
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "DbTree.h"

@interface DbTreeNode () {
    
@public
    
    uint64_t _id;
    
    uint64_t _keys[2 * DBTREE_ORDER - 1];
	
	NSMutableDictionary *_values[2 * DBTREE_ORDER - 1];
    
    uint64_t _childrenIds[2 * DBTREE_ORDER];
    
    DbTreeNode *_childrenNode[2 * DBTREE_ORDER];
    
    uint8_t _length;
    
    bool _leaf;
    
    bool _changed;
    
}

@end

@interface DbTree () {
    
@public
    
    DbTreeNode *_root;
    
    NSUInteger _version;
    
    uint64_t _sequence;
    
    NSString *_name;
    
}

@end

@implementation DbTree

@synthesize changed = _changed;

@synthesize count = _count;

@synthesize memoryDelegate = _memoryDelegate;

@synthesize storageDelegate = _storageDelegate;

- (id)initNamed:(NSString*)name withMemoryDelegate:(id<DbTreeMemoryDelegate>)memoryDelegate withStorageDelegate:(id<DbTreeStorageDelegate>)storageDelegate
{
    if (!(self = [super init])) return nil;
    _name = name;
    _memoryDelegate = memoryDelegate;
    _storageDelegate = storageDelegate;
    if (storageDelegate) {
        if ([storageDelegate hasRecoveryData]) {
            if (![self readRecovery]) {
                return nil;
            }
            if (![storageDelegate removeRecoveryData]) {
                return nil;
            }
        }
        if ([storageDelegate hasStructureData:_name]) {
            NSData *data = [storageDelegate readStructureData:_name];
            NSUInteger offset = 0;
            _version = [data readUByte:&offset];
            _sequence = [data readUInteger64:&offset];
			_count = [data readUInteger64:&offset];
            uint64_t rootId = [data readUInteger64:&offset];
            if (rootId > 0) {
                if (!(_root = [self readNode:rootId])) {
                    return nil;
                }
            }
        }
    }
    return self;
}

- (bool)readRecovery
{
    if (!_storageDelegate) {
        return false;
    }
    if ([_storageDelegate hasRecoveryData]) {
        NSData *data = [_storageDelegate readRecoveryData];
        NSUInteger offset = 0;
        for (;;) {
            uint8_t state = [data readUByte:&offset];
            switch (state) {
                case 1: {
                    NSString *name = [data readString:&offset];
                    NSData *oldData = [data readDataWithSize:&offset];
                    if (![_storageDelegate writeStructureData:name data:oldData]) {
                        return false;
                    }
                    break;
                }
                case 2: {
                    NSString *name = [data readString:&offset];
                    uint64_t id = [data readUInteger64:&offset];
                    bool hasData = [data readBoolean:&offset];
                    if (hasData) {
                        NSData *oldData = [data readDataWithSize:&offset];
                        if (![_storageDelegate writeNodeData:name id:id data:oldData]) {
                            return false;
                        }
                    } else {
                        if (![_storageDelegate removeNodeData:name id:id]) {
                            return false;
                        }
                    }
                    break;
                }
                case 0xFF:
                    return true;
                default:
                    return false;
            }
        }
    }
    return true;
}

- (NSData*)data
{
    NSMutableData *data = [[NSMutableData alloc] init];
    if (!data) {
        return nil;
    }
    [data appendUByte:1];
    [data appendUInteger64:_sequence];
    [data appendUInteger64:_count];
    if (_root) {
        [data appendUInteger64:_root->_id];
    } else {
        [data appendUInteger64:0];
    }
    return data;
}

- (DbTreeNode*)readNode:(uint64_t)id
{
    DbTreeNode *node = _memoryDelegate && [_memoryDelegate respondsToSelector:@selector(allocNode)] ? [_memoryDelegate allocNode] : [[DbTreeNode alloc] init];
    if (!node) {
        return nil;
    }
    NSData *data = [_storageDelegate readNodeData:_name id:id cached:true];
    if (!data) {
        return nil;
    }
    NSUInteger offset = 0;
    [data readUByte:&offset];
    node->_id = [data readUInteger64:&offset];
    if (node->_id != id) {
        return nil;
    }
    node->_leaf = [data readBoolean:&offset];
    node->_length = [data readUByte:&offset];
    for (uint8_t n = 0 ; n < node->_length ; n++) {
        node->_keys[n] = [data readUInteger64:&offset];
        node->_values[n] = [data readDictionary:&offset];
    }
    for (uint8_t n = 0 ; n < node->_length + 1 ; n++) {
        node->_childrenIds[n] = [data readUInteger64:&offset];
    }
    return node;
}

- (void)dealloc
{
    if (_root) {
        [self clearNode:_root deep:true];
        if ([_memoryDelegate respondsToSelector:@selector(freeNode:)]) {
            [_memoryDelegate freeNode:_root];
        }
        _root = nil;
    }
}

- (bool)add:(uint64_t)key value:(NSObject*)value
{
	return [self add:key identify:@[[NSNumber numberWithUnsignedLongLong:key]] value:value];
}

- (bool)add:(uint64_t)key identify:(NSArray*)identify value:(NSObject*)value
{
	if (_root == NULL) {
		_root = _memoryDelegate && [_memoryDelegate respondsToSelector:@selector(allocNode)] ? [_memoryDelegate allocNode] : [[DbTreeNode alloc] init];
        _root->_id = ++_sequence;
        _root->_leaf = true;
		_root->_keys[0] = key;
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		if (!dic) {
			return false;
		}
		dic[identify] = value;
		_root->_values[0] = dic;
		_root->_length = 1;
        _root->_changed = true;
	} else {
		if (_root->_length == 2 * DBTREE_ORDER - 1) {
			DbTreeNode *s = _memoryDelegate && [_memoryDelegate respondsToSelector:@selector(allocNode)] ? [_memoryDelegate allocNode] : [[DbTreeNode alloc] init];
            s->_id = ++_sequence;
            s->_changed = true;
            s->_childrenIds[0] = _root->_id;
			s->_childrenNode[0] = _root;
			if (![self splitChild:s atIndex:0 withNode:_root]) {
                return false;
            }
			int8_t i = 0;
			if (s->_keys[0] < key) {
				i++;
            }
			if (![self insertNonFull:[self nodeChild:s atIndex:i] key:key value:value]) {
                return false;
            }
			_root = s;
		} else {
			if (![self insertNonFull: _root key:key value:value]) {
                return false;
            }
        }
	}
	_count++;
    _changed = true;
    return true;
}

- (bool)has:(uint64_t)key
{
	return [self has:key identify:@[[NSNumber numberWithUnsignedLongLong:key]]];
}

- (bool)has:(uint64_t)key identify:(NSArray *)identify
{
    DbTreeNode *node = [self search:_root key:key];
    if (!node) {
        return false;
    }
    int8_t i = [self findKey:node withKey:key];
    if (key != node->_keys[i]) {
		return false;
	}
	NSDictionary *dic = node->_values[i];
	if (!dic) {
		return false;
	}
	return dic[identify] != nil;
}

- (bool)set:(uint64_t)key value:(NSObject*)value
{
	return [self set:key identify:@[[NSNumber numberWithUnsignedLongLong:key]] value:value];
}

- (bool)set:(uint64_t)key identify:(NSArray*)identify value:(NSObject*)value
{
    DbTreeNode *node = [self search:_root key:key];
    if (!node) {
        return false;
    }
    int8_t i = [self findKey:node withKey:key];
    if (key == node->_keys[i]) {
		NSMutableDictionary *dic = node->_values[i];
		if (!dic[identify]) {
			return false;
		}
		dic[identify] = value;
        node->_changed = true;
        _changed = true;
        return true;
    }
    return false;
}

- (bool)remove:(uint64_t)key
{
	return [self remove:key identify:@[[NSNumber numberWithUnsignedLongLong:key]]];
}

- (bool)remove:(uint64_t)key identify:(NSArray*)identify
{
    if (![self has:key]) {
        return false;
    }
    [self remove:_root atIndex:key];
    if (_root->_length == 0) {
        DbTreeNode *tmp = _root;
        if (_root->_leaf) {
            if (_memoryDelegate && [_memoryDelegate respondsToSelector:@selector(freeNode:)]) {
                [_memoryDelegate freeNode:_root];
            }
            _root = nil;
        } else {
            _root = [self nodeChild:_root atIndex:0];
        }
        [self clearNode:tmp deep:false];
    }
	_count--;
    _changed = true;
    return true;
}

- (NSString*)string
{
    NSMutableString *string = [[NSMutableString alloc] init];
    if (_root) {
        [self string:_root withString:string];
    }
    return string;
}

- (NSObject*)get:(uint64_t)key
{
	return [self get:key identify:@[[NSNumber numberWithUnsignedLongLong:key]]];
}

- (NSObject*)get:(uint64_t)key identify:(NSArray*)identify
{
    DbTreeNode *node = _root ? [self search:_root key:key] : nil;
    if (!node) {
        return nil;
    }
    int8_t i = 0;
	while (i < node->_length && key != node->_keys[i]) {
		i++;
    }
    if (key == node->_keys[i]) {
		NSMutableDictionary *dic = node->_values[i];
		if (!dic) {
			return nil;
		}
		return dic[identify];
    }
    return nil;
}

- (bool)splitChild:(DbTreeNode*)x atIndex:(int8_t)index withNode:(DbTreeNode*)y
{
	DbTreeNode *z = _memoryDelegate && [_memoryDelegate respondsToSelector:@selector(allocNode)] ? [_memoryDelegate allocNode] : [[DbTreeNode alloc] init];
    if (!z) {
        return false;
    }
    z->_id = ++_sequence;
    z->_leaf = y->_leaf;
	z->_length = DBTREE_ORDER - 1;
	for (int8_t j = 0; j < DBTREE_ORDER - 1; j++) {
		z->_keys[j] = y->_keys[j + DBTREE_ORDER];
		z->_values[j] = y->_values[j + DBTREE_ORDER];
    }
	if (!y->_leaf) {
		for (int8_t j = 0; j < DBTREE_ORDER; j++) {
			z->_childrenNode[j] = y->_childrenNode[j + DBTREE_ORDER];
            z->_childrenIds[j] = y->_childrenIds[j + DBTREE_ORDER];
        }
	}
    int8_t len = y->_length;
	y->_length = DBTREE_ORDER - 1;
	for (int8_t j = x->_length; j >= index + 1; j--) {
		x->_childrenNode[j + 1] = x->_childrenNode[j];
        x->_childrenIds[j + 1] = x->_childrenIds[j];
    }
	x->_childrenNode[index + 1] = z;
    x->_childrenIds[index + 1] = z->_id;
	for (int8_t j = x->_length - 1; j >= index; j--) {
		x->_keys[j + 1] = x->_keys[j];
		x->_values[j + 1] = x->_values[j];
    }
	x->_keys[index] = y->_keys[DBTREE_ORDER - 1];
	x->_values[index] = y->_values[DBTREE_ORDER - 1];
	x->_length++;
    for (int8_t j = DBTREE_ORDER - 1; j < len; j++) {
        y->_keys[j] = 0;
        y->_values[j] = nil;
        y->_childrenNode[j+1] = nil;
        y->_childrenIds[j+1] = 0;
    }
    z->_changed = true;
    y->_changed = true;
    x->_changed = true;
    return true;
}

- (bool)insertNonFull:(DbTreeNode*)x key:(uint64_t)key value:(NSObject*)value
{
	return [self insertNonFull:x key:key identify:@[[NSNumber numberWithUnsignedLongLong:key]] value:value];
}

- (bool)insertNonFull:(DbTreeNode*)x key:(uint64_t)key identify:(NSArray*)identify value:(NSObject*)value
{
	int8_t i = x->_length - 1;
	if (x->_leaf) {
		while (i >= 0 && x->_keys[i] > key) {
			x->_keys[i + 1] = x->_keys[i];
			x->_values[i + 1] = x->_values[i];
			i--;
		}
		x->_keys[i + 1] = key;
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
		dic[identify] = value;
		x->_values[i + 1] = dic;
		x->_length++;
        x->_changed = true;
	} else {
		while (i >= 0 && x->_keys[i] > key) {
			i--;
        }
        DbTreeNode *i1 = [self nodeChild:x atIndex:(i+1)];
		if (i1->_length == 2 * DBTREE_ORDER - 1) {
			if (![self splitChild:x atIndex:i + 1 withNode:i1]) {
                return false;
            }
			if (x->_keys[i + 1] < key) {
				i++;
            }
		}
		if (![self insertNonFull:[self nodeChild:x atIndex:(i+1)] key:key value:value]) {
            return false;
        }
	}
    return true;
}

- (NSData*)recovery
{
    if (!_storageDelegate || !_changed) {
        return nil;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    if (!data) {
        return nil;
    }
    [data appendUByte:1];
    [data appendString:_name];
    [data appendDataWithSize:[self data]];
	if (_root && ![self recovery:data name:_name node:_root]) {
		return nil;
	}
    return data;
}

- (bool)recovery:(NSMutableData*)data name:(NSString*)name node:(DbTreeNode*)node
{
    if (!_storageDelegate) {
        return false;
    }
    if (node->_changed) {
        NSData *nodeData = nil;
        if ([_storageDelegate hasNodeData:name id:node->_id]) {
            nodeData = [_storageDelegate readNodeData:name id:node->_id cached:false];
            if (!nodeData) {
                return false;
            }
        }
        [data appendUByte:2];
        [data appendString:name];
        [data appendUInteger64:node->_id];
        [data appendBoolean:nodeData != nil];
        if (nodeData) {
            [data appendDataWithSize:nodeData];
        }
    }
    for (uint8_t n = 0; n <= node->_length ; n++) {
        DbTreeNode *child = node->_childrenNode[n];
        if (child) {
            if (![self recovery:data name:name node:child]) {
                return false;
            }
        }
    }
    return true;
}

- (bool)write
{
    if (!_storageDelegate) {
        return false;
    }
    if (_changed) {
        if (![_storageDelegate writeStructureData:_name data:[self data]]) {
            return false;
        }
        if (_root && ![self write:self->_name node:_root]) {
            return false;
        }
    }
    return true;
}

- (bool)write:(NSString*)name node:(DbTreeNode*)node
{
    if (!_storageDelegate) {
        return false;
    }
    if (node->_changed) {
        NSData *data = [self nodeData:node];
        if (![_storageDelegate writeNodeData:name id:node->_id data:data]) {
            return false;
        }
    }
    for (uint8_t n = 0; n <= node->_length ; n++) {
        DbTreeNode *child = node->_childrenNode[n];
        if (child) {
            [self write:name node:child];
        }
    }
    return true;
}

- (DbTreeNode*)nodeChild:(DbTreeNode*)node atIndex:(uint8_t)index
{
    DbTreeNode *child = node->_childrenNode[index];
    if (child) {
        if (_memoryDelegate && [_memoryDelegate respondsToSelector:@selector(checkPoint:)]) {
            [_memoryDelegate checkPoint:child];
        }
        return child;
    }
    if (!_storageDelegate) {
        return nil;
    }
    uint64_t id = node->_childrenIds[index];
    child = [self readNode:id];
    if (!child) {
        return nil;
    }
    node->_childrenNode[index] = child;
    return child;
}


- (DbTreeNode*)search:(DbTreeNode*)node key:(uint64_t)key
{
    if (!node) {
        return nil;
    }
	int8_t i = 0;
	while (i < node->_length && key > node->_keys[i]) {
		i++;
    }
	if (node->_keys[i] == key) {
		return node;
    }
	if (node->_leaf) {
		return nil;
    }
    DbTreeNode *child = [self nodeChild:node atIndex:i];
	return [self search:child key:key];
}

- (bool)remove:(DbTreeNode*)node atIndex:(uint64_t)key
{
	int8_t idx = [self findKey:node withKey:key];
	if (idx < node->_length && node->_keys[idx] == key) {
		if (node->_leaf) {
			[self removeFromLeaf:node atIndex:idx];
		} else {
			[self removeFromNonLeaf:node atIndex:idx];
        }
	} else {
		if (node->_leaf) {
			return false;
		}
		bool flag = ((idx == node->_length) ? true : false);
        DbTreeNode *child = [self nodeChild:node atIndex:idx];
        if (!child) {
            return false;
        }
		if (child->_length < DBTREE_ORDER) {
			[self fill:node atIndex:idx];
        }
		if (flag && idx > node->_length) {
            child = [self nodeChild:node atIndex:(idx - 1)];
        } else {
            child = [self nodeChild:node atIndex:idx];
        }
        if (!child) {
            return false;
        }
        [self remove:child atIndex:key];
	}
    return true;
}

- (void)removeFromLeaf:(DbTreeNode*)node atIndex:(int8_t)idx
{
	for (int8_t i = idx + 1; i < node->_length; ++i) {
		node->_keys[i - 1] = node->_keys[i];
        node->_values[i - 1] = node->_values[i];
    }
    {
        node->_length--;
        node->_keys[node->_length] = 0;
        node->_values[node->_length] = nil;
    }
    node->_changed = true;
}

- (bool)removeFromNonLeaf:(DbTreeNode*)node atIndex:(int8_t)idx
{
	uint64_t k = node->_keys[idx];
	if (node->_childrenNode[idx]->_length >= DBTREE_ORDER) {
		DbTreeNode *predNode = [self getPred:node atIndex:idx];
        if (!predNode) {
            return false;
        }
        if (node->_values[idx]) {
            if ([_memoryDelegate respondsToSelector:@selector(freeValue:)]) {
                [_memoryDelegate freeValue:node->_values[idx]];
            }
        }
		node->_keys[idx] = predNode->_keys[predNode->_length - 1];
        node->_values[idx] = predNode->_values[predNode->_length - 1];
        node->_changed = true;
        DbTreeNode *child = [self nodeChild:node atIndex:idx];
        if (!child) {
            return false;
        }
		if (![self remove:child atIndex:node->_keys[idx]]) {
            return false;
        }
	} else if (node->_childrenNode[idx + 1]->_length >= DBTREE_ORDER) {
		DbTreeNode *succNode = [self getSucc:node atIndex:idx];
        if (!succNode) {
            return nil;
        }
        if (node->_values[idx]) {
            if ([_memoryDelegate respondsToSelector:@selector(freeValue:)]) {
                [_memoryDelegate freeValue:node->_values[idx]];
            }
        }
		node->_keys[idx] = succNode->_keys[0];
		node->_values[idx] = succNode->_values[0];
        node->_changed = true;
        DbTreeNode *child = [self nodeChild:node atIndex:(idx + 1)];
		if (![self remove:child atIndex:node->_keys[idx]]) {
            return false;
        }
	} else {
		if (![self merge:node atIndex:idx]) {
            return false;
        }
        DbTreeNode *child = [self nodeChild:node atIndex:idx];
        if(!child){
            return false;
        }
		if (![self remove:child atIndex:k]) {
            return false;
        }
	}
    return true;
}

- (DbTreeNode*)getPred:(DbTreeNode*)node atIndex:(int8_t)idx
{
	DbTreeNode *cur = [self nodeChild:node atIndex:idx];
    if (!cur) {
        return nil;
    }
	while (!cur->_leaf) {
        if (!(cur = [self nodeChild:cur atIndex:cur->_length])) {
            return nil;
        }
    }
	return cur;
}

- (DbTreeNode*)getSucc:(DbTreeNode*)node atIndex:(int8_t)idx
{
	DbTreeNode *cur = [self nodeChild:node atIndex:(idx + 1)];
    if (!cur) {
        return nil;
    }
	while (!cur->_leaf) {
        if (!(cur = [self nodeChild:cur atIndex:0])) {
            return nil;
        }
    }
	return cur;
}

- (bool)fill:(DbTreeNode*)node atIndex:(int8_t)idx
{
    if (idx != 0) {
        DbTreeNode *child = [self nodeChild:node atIndex:(idx - 1)];
        if (!child) {
            return false;
        }
        if (child->_length >= DBTREE_ORDER) {
            [self borrowFromPrev:node atIndex:idx];
            return true;
        }
    } else if (idx != node->_length){
        DbTreeNode *child = [self nodeChild:node atIndex:(idx + 1)];
        if (!child) {
            return false;
        }
        if (child->_length >= DBTREE_ORDER) {
            [self borrowFromNext:node atIndex:idx];
            return true;
        }
    }
    if (idx != node->_length) {
        if (![self merge:node atIndex:idx]) {
            return false;
        }
    } else {
        if (![self merge:node atIndex:(idx - 1)]) {
            return false;
        }
    }
    return true;
}

- (void)borrowFromPrev:(DbTreeNode*)node atIndex:(int8_t)idx
{
	DbTreeNode *child = [self nodeChild:node atIndex:idx];
	DbTreeNode *sibling = [self nodeChild:node atIndex:(idx - 1)];
	for (int8_t i = child->_length - 1; i >= 0; --i) {
		child->_keys[i + 1] = child->_keys[i];
        child->_values[i + 1] = child->_values[i];
    }
	if (!child->_leaf) {
		for (int8_t i = child->_length; i >= 0; --i) {
			child->_childrenNode[i + 1] = child->_childrenNode[i];
            child->_childrenIds[i + 1] = child->_childrenIds[i];
        }
	}
	child->_keys[0] = node->_keys[idx - 1];
    child->_values[0] = node->_values[idx - 1];
	if (!node->_leaf) {
		child->_childrenNode[0] = sibling->_childrenNode[sibling->_length];
        child->_childrenIds[0] = sibling->_childrenIds[sibling->_length];
    }
	node->_keys[idx - 1] = sibling->_keys[sibling->_length - 1];
    node->_values[idx - 1] = sibling->_values[sibling->_length - 1];
	child->_length++;
    {
        sibling->_childrenNode[sibling->_length] = nil;
        sibling->_childrenIds[sibling->_length] = 0;
        sibling->_length--;
        sibling->_values[sibling->_length] = nil;
        sibling->_keys[sibling->_length] = 0;
    }
    child->_changed = true;
    sibling->_changed = true;
    _changed = true;
}

- (void)borrowFromNext:(DbTreeNode*)node atIndex:(int8_t)idx
{
	DbTreeNode *child = [self nodeChild:node atIndex:idx];
	DbTreeNode *sibling = [self nodeChild:node atIndex:(idx + 1)];
	child->_keys[(child->_length)] = node->_keys[idx];
    child->_values[(child->_length)] = node->_values[idx];
	if (!(child->_leaf)) {
		child->_childrenNode[(child->_length) + 1] = sibling->_childrenNode[0];
        child->_childrenIds[(child->_length) + 1] = sibling->_childrenIds[0];
    }
	node->_keys[idx] = sibling->_keys[0];
    node->_values[idx] = sibling->_values[0];
	for (int8_t i = 1; i < sibling->_length; ++i) {
		sibling->_keys[i - 1] = sibling->_keys[i];
        sibling->_values[i - 1] = sibling->_values[i];
    }
	if (!sibling->_leaf) {
		for (int8_t i = 1; i <= sibling->_length; ++i) {
			sibling->_childrenNode[i - 1] = sibling->_childrenNode[i];
            sibling->_childrenIds[i - 1] = sibling->_childrenIds[i];
        }
	}
	child->_length++;
    {
        sibling->_childrenNode[sibling->_length] = nil;
        sibling->_childrenIds[sibling->_length] = 0;
        sibling->_length--;
        sibling->_values[sibling->_length] = nil;
        sibling->_keys[sibling->_length] = 0;
    }
    child->_changed = true;
    sibling->_changed = true;
    _changed = true;
}

- (bool)merge:(DbTreeNode*)node atIndex:(int8_t)idx
{
	DbTreeNode *child = [self nodeChild:node atIndex:idx];
    if (!child) {
        return false;
    }
	DbTreeNode *sibling = [self nodeChild:node atIndex:(idx + 1)];
    if (!sibling) {
        return false;
    }
	child->_keys[DBTREE_ORDER - 1] = node->_keys[idx];
    child->_values[DBTREE_ORDER - 1] = node->_values[idx];
	for (int8_t i = 0; i < sibling->_length; ++i) {
		child->_keys[i + DBTREE_ORDER] = sibling->_keys[i];
        child->_values[i + DBTREE_ORDER] = sibling->_values[i];
    }
	if (!child->_leaf) {
		for (int8_t i = 0; i <= sibling->_length; ++i) {
			child->_childrenNode[i + DBTREE_ORDER] = sibling->_childrenNode[i];
            child->_childrenIds[i + DBTREE_ORDER] = sibling->_childrenIds[i];
        }
	}
	for (int8_t i = idx + 1; i < node->_length; ++i) {
		node->_keys[i - 1] = node->_keys[i];
        node->_values[i - 1] = node->_values[i];
    }
	for (int8_t i = idx + 2; i <= node->_length; ++i) {
		node->_childrenNode[i - 1] = node->_childrenNode[i];
        node->_childrenIds[i - 1] = node->_childrenIds[i];
    }
	child->_length += sibling->_length + 1;
    for (int8_t n = 0; n < 2 * DBTREE_ORDER ; n++) {
        sibling->_childrenIds[n] = 0;
        sibling->_childrenNode[n] = nil;
    }
	[self clearNode:sibling deep:false];
    if ([_memoryDelegate respondsToSelector:@selector(freeNode:)]) {
        [_memoryDelegate freeNode:sibling];
    }
    {
        node->_childrenNode[node->_length] = nil;
        node->_childrenIds[node->_length] = 0;
        node->_length--;
        node->_keys[node->_length] = 0;
        node->_values[node->_length] = nil;
    }
    child->_changed = true;
    _changed = true;
    return true;
}

- (void)string:(DbTreeNode*)node withString:(NSMutableString*)string
{
	int8_t i;
	for (i = 0; i < node->_length; i++) {
		if (!node->_leaf) {
			[self string:[self nodeChild:node atIndex:i] withString:string];
        }
        [string appendFormat:@" %lld", node->_keys[i]];
	}
	if (!node->_leaf) {
		[self string:[self nodeChild:node atIndex:i] withString:string];
    }
}

- (void)clearNode:(DbTreeNode*)node deep:(bool)deep
{
    node->_id = 0;
    node->_changed = false;
    node->_leaf = false;
    node->_length = 0;
    for (int8_t n = 0; n < 2 * DBTREE_ORDER - 1 ; n++) {
        node->_keys[n] = 0;
		[node->_values[n] removeAllObjects];
        node->_values[n] = nil;
    }
    for (int8_t n = 0; n < 2 * DBTREE_ORDER ; n++) {
        if (node->_childrenNode[n]) {
            DbTreeNode *child = node->_childrenNode[n];
            if (_memoryDelegate && [_memoryDelegate respondsToSelector:@selector(freeNode:)]) {
                [_memoryDelegate freeNode:child];
            }
            if (deep) {
                [self clearNode:child deep:deep];
            }
            node->_childrenNode[n] = nil;
        }
        node->_childrenIds[n] = 0;
    }
}

- (int8_t)findKey:(DbTreeNode*)node withKey:(uint64_t)key
{
    int8_t idx = 0;
	while (idx < node->_length && node->_keys[idx] < key) {
		++idx;
    }
	return idx;
}

- (NSData*)nodeData:(DbTreeNode*)node
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendUByte:1];
    [data appendUInteger64:node->_id];
    [data appendBoolean:node->_leaf];
    [data appendUByte:node->_length];
    for (uint8_t n = 0 ; n < node->_length ; n++) {
        [data appendUInteger64:node->_keys[n]];
        [data appendDictionary:node->_values[n]];
    }
    for (uint8_t n = 0 ; n < node->_length + 1 ; n++) {
        [data appendUInteger64:node->_childrenIds[n]];
    }
    return data;
}

@end

@implementation DbTreeNode

@end
