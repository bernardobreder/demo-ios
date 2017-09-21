//
//  DbIndexTree.m
//  iSql
//
//  Created by Bernardo Breder on 16/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "DbIndexTree.h"

@interface DbIndexTree () {
	@protected
	DbIndexTreeNode *_root;
}

//@property (nonatomic, strong, readonly) DbIndexTreeNode *root;

@end

@interface Db1IndexTree ()

@end

@implementation Db1IndexTree

- (IdArray*)get:(uint64_t)key
{
	DbIndexTreeNode *p = [self getNode:key];
	return nil;
//    return p == nil ? 0 : p.value;
}

- (bool)add:(uint64_t)key value:(uint64_t)value
{
	return false;
}

- (bool)set:(uint64_t)key value:(uint64_t)value
{
	return false;
}

- (bool)remove:(uint64_t)key
{
	return false;
}

- (bool)has:(uint64_t)key value:(uint64_t)value
{
	return false;
}

- (NSData*)recoveryData
{
	return nil;
}

- (NSData*)structureData
{
	return nil;
}

- (NSData*)nodeData:(DbIndexTreeNode*)node
{
	return nil;
}

- (DbIndexTreeNode*)getNode:(uint64_t)key1
{
    Db1IndexTreeNode *p = (Db1IndexTreeNode*)_root;
    while (p) {
        int64_t cmp = key1 - p.key1;
        if (cmp < 0) {
            p = (Db1IndexTreeNode*)p.left;
        } else if (cmp > 0) {
            p = (Db1IndexTreeNode*)p.right;
        } else {
            return p;
        }
    }
    return 0;
}


@end

@implementation DbIndexTree

//@synthesize root = _root;

@synthesize name = _name;

@synthesize size = _size;

@synthesize changed = _changed;

- (id)init:(NSString*)name
{
	if (!(self = [super init])) return nil;
	_name = name;
	return self;
}

#define b_treemap_entry_red false
#define b_treemap_entry_black true
#define b_treemap_entry_set_color(p,c) if (p) { p.black = c; }
#define b_treemap_entry_color(p) (!p ? true : p.black)
#define b_treemap_entry_right(p) (!p ? 0: p.right)
#define b_treemap_entry_left(p) (!p ? 0: p.left)
#define b_treemap_entry_parent(p) (!p ? 0: p.parent)

//- (bool)add:(NSInteger)key value:(uint64_t)value
//{
//    DbIndexTreeNode* aux = _root;
//    if (!aux) {
//        DbIndexTreeNode* entry = [[NSTreeNode alloc] init];
//        if (!entry) {
//            return false;
//        }
//        entry.key = key;
//        entry.value = value;
//        _root = entry;
//        _size++;
//        return true;
//    }
//    DbIndexTreeNode* parent;
//    int64_t cmp;
//    do {
//        parent = aux;
//        cmp = key - aux.key;
//        if (cmp < 0) {
//            aux = aux.left;
//        } else if (cmp > 0) {
//            aux = aux.right;
//        } else {
//            aux.value = value;
//            return true;
//        }
//    } while (aux);
//    DbIndexTreeNode* entry = [[NSTreeNode alloc] init];
//    if (!entry) {
//        return false;
//    }
//    entry.key = key;
//    entry.value = value;
//    entry.parent = parent;
//    if (cmp < 0) {
//        parent.left = entry;
//    } else {
//        parent.right = entry;
//    }
//    [self fixAfterInsertion:entry];
//    _size++;
//    return true;
//}

- (bool)fixAfterInsertion:(DbIndexTreeNode*)x
{
    x.black = b_treemap_entry_red;
	while (x && x != _root && x.parent.black == b_treemap_entry_red) {
		if (b_treemap_entry_parent(x) == b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)))) {
			DbIndexTreeNode* y = b_treemap_entry_right(b_treemap_entry_parent(b_treemap_entry_parent(x)));
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
			DbIndexTreeNode* y = b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)));
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

- (void)fixAfterDeletion:(DbIndexTreeNode*)x
{
	while (x != _root && b_treemap_entry_color(x) == b_treemap_entry_black) {
		if (x == b_treemap_entry_left(b_treemap_entry_parent(x))) {
			DbIndexTreeNode* sib = b_treemap_entry_right(b_treemap_entry_parent(x));
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
			DbIndexTreeNode* sib = b_treemap_entry_left(b_treemap_entry_parent(x));
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

- (void)removeNode:(DbIndexTreeNode*)p
{
	_size--;
	if (p.left && p.right) {
		DbIndexTreeNode* s = [p next];
		[p swapKey:s];
		p.value = s.value;
		p = s;
	}
	DbIndexTreeNode* replacement = p.left ? p.left : p.right;
	if (replacement) {
		replacement.parent = p.parent;
		if (!p.parent) {
			_root = replacement;
		} else if (p == p.parent.left) {
			p.parent.left = replacement;
		} else {
			p.parent.right = replacement;
		}
		p.left = p.right = p.parent = nil;
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
			} else if (p == p.parent.right) {
				p.parent.right = nil;
			}
			p.parent = nil;
		}
	}
}

- (void)rotateLeft:(DbIndexTreeNode*)p
{
    if (p) {
        DbIndexTreeNode* r = p.right;
		p.right = r.left;
		if (r.left) {
			r.left.parent = p;
		}
		r.parent = p.parent;
        if (!p.parent) {
			_root = r;
		} else if (p.parent.left == p) {
			p.parent.left = r;
        } else {
			p.parent.right = r;
		}
		r.left = p;
		p.parent = r;
	}
}

- (void)rotateRight:(DbIndexTreeNode*)p
{
    if (p) {
		DbIndexTreeNode* l = p.left;
		p.left = l.right;
		if (l.right) {
			l.right.parent = p;
		}
		l.parent = p.parent;
		if (!p.parent) {
			_root = l;
		} else if (p.parent.right == p) {
			p.parent.right = l;
		} else {
			p.parent.left = l;
		}
		l.right = p;
		p.parent = l;
	}
}

- (NSData*)recoveryData
{
	return nil;
}

- (NSData*)structureData
{
	return nil;
}

- (NSData*)nodeData:(DbIndexTreeNode*)node
{
	return nil;
}

@end

@implementation Db1IndexTreeNode

- (void)swapKey:(DbIndexTreeNode*)node
{
	self.key1 = ((Db1IndexTreeNode*)node).key1;
}

- (int64_t)compare:(DbIndexTreeNode*)node
{
	return self.key1 - ((Db1IndexTreeNode*)node).key1;
}

@end

@implementation DbIndexTreeNode

- (void)swapKey:(DbIndexTreeNode*)node;
{
}

- (int64_t)compare:(DbIndexTreeNode*)node
{
	return 0;
}

- (DbIndexTreeNode*)next
{
    DbIndexTreeNode* p;
    if (_right) {
		p = _right;
		while (p.left) {
			p = p.left;
        }
		return p;
	} else {
		p = _parent;
		DbIndexTreeNode* ch = self;
		while (p && ch == p.right) {
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

@end
