//
//  NSTree.m
//  iSql
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "NSTree.h"

@implementation NSTree

@synthesize root = _root;
@synthesize size = _size;

- (bool)add:(NSInteger)key value:(NSObject*)value
{
    NSTreeNode* aux = _root;
    if (!aux) {
        NSTreeNode* entry = [[NSTreeNode alloc] init];
        if (!entry) {
            return false;
        }
        entry.key = key;
        entry.value = value;
        _root = entry;
        _size++;
        return true;
    }
    NSTreeNode* parent;
    NSInteger cmp;
    do {
        parent = aux;
        cmp = key - aux.key;
        if (cmp < 0) {
            aux = aux.left;
        } else if (cmp > 0) {
            aux = aux.right;
        } else {
            aux.value = value;
            return true;
        }
    } while (aux);
    NSTreeNode* entry = [[NSTreeNode alloc] init];
    if (!entry) {
        return false;
    }
    entry.key = key;
    entry.value = value;
    entry.parent = parent;
    if (cmp < 0) {
        parent.left = entry;
    } else {
        parent.right = entry;
    }
    [self fixAfterInsertion:entry];
    _size++;
    return true;
}

- (NSObject*)get:(NSInteger)key
{
    NSTreeNode *p = [self getNode:key];
    return !p ? 0 : p.value;
}

- (bool)set:(NSInteger)key value:(NSObject*)value
{
    NSTreeNode* p = [self getNode:key];
	if (p) {
        p.value = value;
        return true;
	}
    return false;
}

- (bool)remove:(NSInteger)key
{
    NSTreeNode* p = [self getNode:key];
	if (p) {
        [self removeNode:p];
        return true;
	}
    return false;
}

- (NSTreeNode*)first
{
    NSTreeNode* p = _root;
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
    _root = nil;
    _size = 0;
}

#define b_treemap_entry_red false
#define b_treemap_entry_black true
#define b_treemap_entry_set_color(p,c) if (p) { p.black = c; }
#define b_treemap_entry_color(p) (!p ? true : p.black)
#define b_treemap_entry_right(p) (!p ? 0: p.right)
#define b_treemap_entry_left(p) (!p ? 0: p.left)
#define b_treemap_entry_parent(p) (!p ? 0: p.parent)

- (NSTreeNode*)getNode:(NSInteger)key
{
    NSTreeNode *p = _root;
    while (p) {
        NSInteger cmp = key - p.key;
        if (cmp < 0) {
            p = p.left;
        } else if (cmp > 0) {
            p = p.right;
        } else {
            return p;
        }
    }
    return 0;
}

- (bool)fixAfterInsertion:(NSTreeNode*)x
{
    x.black = b_treemap_entry_red;
	while (x && x != _root && x.parent.black == b_treemap_entry_red) {
		if (b_treemap_entry_parent(x) == b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)))) {
			NSTreeNode* y = b_treemap_entry_right(b_treemap_entry_parent(b_treemap_entry_parent(x)));
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
			NSTreeNode* y = b_treemap_entry_left(b_treemap_entry_parent(b_treemap_entry_parent(x)));
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

- (void)fixAfterDeletion:(NSTreeNode*)x
{
	while (x != _root && b_treemap_entry_color(x) == b_treemap_entry_black) {
		if (x == b_treemap_entry_left(b_treemap_entry_parent(x))) {
			NSTreeNode* sib = b_treemap_entry_right(b_treemap_entry_parent(x));
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
			NSTreeNode* sib = b_treemap_entry_left(b_treemap_entry_parent(x));
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

- (void)removeNode:(NSTreeNode*)p
{
	_size--;
	if (p.left && p.right) {
		NSTreeNode* s = [p next];
		p.key = s.key;
		p.value = s.value;
		p = s;
	}
	NSTreeNode* replacement = p.left ? p.left : p.right;
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

- (void)rotateLeft:(NSTreeNode*)p
{
    if (p) {
        NSTreeNode* r = p.right;
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

- (void)rotateRight:(NSTreeNode*)p
{
    if (p) {
		NSTreeNode* l = p.left;
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

@end

@implementation NSTreeNode

@synthesize key = _key;
@synthesize value = _value;
@synthesize left = _left;
@synthesize right = _right;
@synthesize parent = _parent;
@synthesize black = _black;

- (NSTreeNode*)next
{
    register NSTreeNode* p;
    if (_right) {
		p = _right;
		while (p.left) {
			p = p.left;
        }
		return p;
	} else {
		p = _parent;
		NSTreeNode* ch = self;
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