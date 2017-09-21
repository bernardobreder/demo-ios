//
//  NSTree.m
//  NSTree
//
//  Created by . Carlin on 10/16/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import "NSBTree.h"

#define DEFAULT_NODE_CAPACITY 20

#pragma mark - NSTreeNode

@implementation NSTreeNode

- (id)init
{
    if (!(self = [super init])) return nil;
    _data = [NSMutableArray new];
    _children = [NSMutableArray new];
    _changed = true;
    return self;
}

- (id)initWithParent:(NSTreeNode *)parent
{
    if (!(self = [super init])) return nil;
    _parent = parent;
    _data = [NSMutableArray new];
    _children = [NSMutableArray new];
    _changed = true;
    return self;
}

/** @brief Get index of node in children array */
- (NSUInteger)indexOfChildNode:(NSTreeNode *)child
{
    return [self.children indexOfObject:child];
}

/** @brief Get index of object in data array */
- (NSUInteger)indexOfDataObject:(id)object
{
    return [self.data indexOfObject:object inSortedRange:NSMakeRange(0, self.data.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

@end

#pragma mark - NSTree

@interface NSTree()

@property (nonatomic, strong) NSTreeNode *root;
@property (nonatomic, assign) int nodeMinimum;
@property (nonatomic, assign, readwrite) int nodeCapacity;
@property (nonatomic, assign, readwrite) int count;

@end

@implementation NSTree

#pragma mark - Constructors

- (id)init
{
    if (!(self = [super init])) return nil;
    _nodeCapacity = DEFAULT_NODE_CAPACITY;
    _nodeMinimum = _nodeCapacity / 2;
    _root = [NSTreeNode new];
    return self;
}

#pragma mark - Public Methods

/** @brief Add object to tree, true if successful */
- (bool)addObject:(id)object
{
    if (!object) {
        return false;
    }
    NSTreeNode *node = [self getLeafNodeForObject:object inNode:self.root];
    if ([self addObject:object withChild:nil toNode:node]) {
        self.count++;
        return true;
    }
    return false;
}

/** @brief Remove object from tree, returns false if not in tree */
- (bool)removeObject:(id)object
{
    if (!object || self.root.data.count <= 0) {
        return false;
    }
    NSTreeNode *node = [self getFirstNodeThatContains:object inBranch:self.root];
    if ([self removeObject:object fromNode:node]) {
        self.count--;
        return true;
    }
    return false;
}

/** @brief Search for object in tree, returns false if not found */
- (bool)containsObject:(id)object
{
    if (!object || self.root.data.count <= 0) {
        return false;
    }
    NSTreeNode *node = [self getFirstNodeThatContains:object inBranch:self.root];
    return node != nil;
}

/** @brief Returns true if tree is empty */
- (bool)isEmpty
{
    return (self.root.data.count == 0);
}

/** @brief Returns minimum element, or nil if none */
- (id)minimum
{
    if (self.root.data.count) {
        NSTreeNode *node = [self getLeftMostNode:self.root];
        if (node.data && node.data.count) {
            return [node.data objectAtIndex:0];
        }
    }
    return nil;
}

/** @brief Returns maximum element, or nil if none */
- (id)maximum
{
    if (self.root.data.count) {
        NSArray *data = [[self getRightMostNode:self.root] data];
        return [data objectAtIndex:data.count - 1];
    }
    return nil;
}

/** @brief Returns printout of the tree */
- (NSString*)printTree
{
    NSMutableString *result = [NSMutableString new];
    [self traverse:^bool(NSTreeNode *node, id data, id extra) {
        NSMutableString *padding = [NSMutableString new];
        for (NSTreeNode *parent = node.parent; parent; parent = parent.parent) {
            [padding appendString:@"\t"];
        }
        [extra appendString:[NSString stringWithFormat:@"%@%@%@\n", padding, data, (node.changed?@"*":@"")]];
        return true;
    } extraData:result onTree:self.root withAlgorithm:NSTreeTraverseAlgorithmInorder];
    return result;
}

/** @brief Returns printout of the tree */
- (void)markAsUnchanged
{
    NSMutableString *result = [NSMutableString new];
    [self traverse:^bool(NSTreeNode *node, id data, id extra) {
        node.changed = false;
        return true;
    } extraData:result onTree:self.root withAlgorithm:NSTreeTraverseAlgorithmInorder];
}

/** @brief Traverse the tree in sorted order while executing block on every element
 @param block Traversal block to be called on data as we traverse
 @param extra User defined object that will be passed to block to help do things like aggregate calculations.
 @param algo Traversal algorithm: inorder, postorder, preorder, bfs
 @return bool TRUE if traversed through entire tree, FALSE if cut short by traversal block
 */
- (bool)traverse:(NSTreeTraverseBlock)block extraData:(id)extra withAlgorithm:(NSTreeTraverseAlgorithm)algo
{
    return [self traverse:block extraData:extra onTree:self.root withAlgorithm:algo];
}

#pragma mark - Tree Methods

/** @brief Adds an object to a node in sorted order, with an accompanying child branch if relevant.
 @param object Object to be added.
 @param child Child branch to add to node after the data is added.
 @param node Node to add the data to.
 @return bool True if adding is successful, false if error
 */
- (bool)addObject:(id)object withChild:(NSTreeNode *)child toNode:(NSTreeNode *)node
{
    if (!object || !node) {
        return false;
    }
    // Find index where we should put it, and add it
    NSInteger index = [node.data indexOfObject:object inSortedRange:NSMakeRange(0, node.data.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    [node.data insertObject:object atIndex:index];
    // Add child if exists, need to add right after data insertion
    if (child)
    {
        // Insert & change parent pointer
        [node.children insertObject:child atIndex:index + 1];
        child.parent = node;
        child.changed = true;
        // Switch up sibling pointers
        NSTreeNode *sibling = node.children[index];
        if (sibling) {
            sibling.changed = true;
            child.next = sibling.next;
            child.previous = sibling;
            child.previous.next = child;
            if (child.next) {
                child.next.previous = child;
            }
        }
    }
    // Rebalance as needed
    [self rebalanceNode:node];
    node.changed = true;
    return true;
}

/** @brief Removes an object from a node
 @param object Object to be removed.
 @param node Node to remove object from.
 @return bool True if removed, false if not found or if there was an error.
 */
- (bool)removeObject:(id)object fromNode:(NSTreeNode *)node
{
    if (!object || !node || node.data.count <= 0) {
        return false;
    }
    // Get index to remove from
    int index = [node indexOfDataObject:object];
    if (index == NSNotFound) {
        return false;
    }
    // If leaf node, simple remove
    if (!node.children.count)
    {
        // If we use removeObject:(id) it removes all occurrences
        [node.data removeObjectAtIndex:index];
        
        // Rebalance as needed
        [self rebalanceNode:node];
    }
    else    // Deal with replacing separator
    {
        // Replace with smallest value from right subtree
        NSTreeNode *child = [self getLeftMostNode:node.children[index + 1]];
        id replacementObject = child.data[0];
        [node.data replaceObjectAtIndex:index withObject:replacementObject];
        [child.data removeObjectAtIndex:0];
        // Rebalance child node if needed
        [self rebalanceNode:child];
    }
    return true;
}

/** @brief Returns the first node that contains the given object using standard comparison rules, starting from given node branch. */
- (NSTreeNode *)getFirstNodeThatContains:(id)object inBranch:(NSTreeNode *)node
{
    if (!object || !node || !node.data.count) {
        return nil;
    }
    // Search for item in node data
    int index = [node.data indexOfObject:object inSortedRange:NSMakeRange(0, node.data.count) options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    // If within bounds of data (note the <= count due to subtree indexing)
    if (index >= 0 && index <= node.data.count)
    {
        // Check if item is equal at index
        if (index < node.data.count && [node.data[index] compare:object] == NSOrderedSame) {
            return node;
        }
        // If has children, need to search subtree
        if (node.children.count) {
            return [self getFirstNodeThatContains:object inBranch:node.children[index]];
        }
    }
    return nil;
}

/** @brief Returns the lowest node that contains the given object using standard comparison rules, starting from given node branch. */
- (NSTreeNode *)getLowestNodeThatContains:(id)object inBranch:(NSTreeNode *)node
{
    if (!object || !node || !node.data.count) {
        return nil;
    }
    // Search for item in node data
    int index = [node.data indexOfObject:object inSortedRange:NSMakeRange(0, node.data.count) options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    // If within bounds of data (note the <= count due to subtree indexing)
    if (index >= 0 && index <= node.data.count)
    {
        // Search subtree (don't terminate early on find because it's worth finding and deleting from leaf node to prevent restructuring)
        NSTreeNode *child = nil;
        if (node.children.count) {
            child = [self getLowestNodeThatContains:object inBranch:node.children[index]];
        }
        // If item exists and is equal at index and no child with value exists, then use as return value
        if (index < node.data.count && [node.data[index] compare:object] == NSOrderedSame) {
            return (child) ? child : node;
        }
        return child;
    }
    return nil;
}

/** @brief Searches for and returns the appropriate leaf node for an object to be inserted, starting from given node. */
- (NSTreeNode *)getLeafNodeForObject:(id)object inNode:(NSTreeNode *)node
{
    if (!object || !node) {
        return nil;
    }
    // If there are children, go farther down
    if (node.children.count)
    {
        // Search for item in node data
        int index = [node.data indexOfObject:object inSortedRange:NSMakeRange(0, node.data.count) options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        // If within bounds of children
        if (index >= 0 && index < node.children.count) {
            return [self getLeafNodeForObject:object inNode:node.children[index]];
        } else {
            return nil;     // This shouldn't happen!
        }
    }
    else {  // Found the node
        return node;
    }
}

/** @brief Returns left-most node in tree starting from given node */
- (NSTreeNode *)getLeftMostNode:(NSTreeNode *)node
{
    while (node.children.count) {
        node = node.children[0];
    }
    return node;
}

/** @brief Returns right-most node in tree starting from given node */
- (NSTreeNode *)getRightMostNode:(NSTreeNode *)node
{
    while (node.children.count) {
        node = node.children[node.children.count-1];
    }
    return node;
}

/** @brief Traverse the tree in sorted order while executing block on every element
 @param block Traversal block to be called on data as we traverse
 @param extra User defined object that will be passed to block to help do things like aggregate calculations.
 @param root Tree to traverse starting at given node
 @param algo Traversal algorithm: inorder, postorder, preorder, bfs
 @return bool TRUE if traversed through entire tree, FALSE if cut short by traversal block
 */
- (bool)traverse:(NSTreeTraverseBlock)block extraData:(id)extra onTree:(NSTreeNode *)root withAlgorithm:(NSTreeTraverseAlgorithm)algo
{
    // Return condition
    if (!root) {
        return true;
    }
    // If Breadth First traversal
    if (algo == NSTreeTraverseAlgorithmBreadthFirst) {
        // Go through data
        for (int i = 0; i < root.data.count; ++i) {
            if (!block(root, root.data[i], extra)) {
                return false;   // If block cuts traversal short
            }
        }
        // Go to next sibling node, or next level's leftmost node
        if (root.next) {
            if (![self traverse:block extraData:extra onTree:root.next withAlgorithm:algo]) {
                return false;   // If block cuts traversal short
            }
        }
        else { // Find next level's leftmost node
            // Go to leftmost node in current level
            NSTreeNode *node = root;
            while (node.previous) {
                node = node.previous;
            }
            
            // Start traversal on it's leftmost child
            if (node.children.count) {
                if (![self traverse:block extraData:extra onTree:node.children[0] withAlgorithm:algo]) {
                    return false;   // Traversal cut short
                }
            } else {
                return true;
            }
        }
    }
    else {   // Depth First traversal
        if (algo == NSTreeTraverseAlgorithmPostorder) {
            for (int i = 0; i < root.children.count; ++i) {
                if (![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo]) {
                    return false;   // Traversal cut short
                }
            }
        }
        // Process data, note the <= count for subtree traversal
        for (int i = 0; i <= root.data.count; ++i) {
            // Process subtrees in order
            if (algo == NSTreeTraverseAlgorithmInorder
                && i < root.children.count) {
                if (![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo]) {
                    return false;   // Traversal cut short
                }
            }
            // Process data in order
            if (i < root.data.count) {
                if (!block(root, root.data[i], extra)) {
                    return false;   // Traversal cut short
                }
            }
        }
        if (algo == NSTreeTraverseAlgorithmPreorder) {
            for (int i = 0; i < root.children.count; ++i) {
                if (![self traverse:block extraData:extra onTree:root.children[i] withAlgorithm:algo]) {
                    return false;   // Traversal cut short
                }
            }
        }
    }
    return true;
}

- (void)rebalanceNode:(NSTreeNode *)node
{
    // If node is at capacity, need to split
    if (node.data.count > self.nodeCapacity)
    {
        // Create right node to be efficient about removing from arrays
        NSTreeNode *newRightNode = [[NSTreeNode alloc] initWithParent:node.parent];
        int middle = node.data.count / 2;
        int childIndex = middle + 1;
        id object = node.data[middle];
        // Iterate through data & children from middle + 1 and add to new node
        for (int i = childIndex; i < node.data.count; ++i) {
            [newRightNode.data addObject:node.data[i]];
        }
        for (int i = childIndex; i < node.children.count; ++i) {
            [newRightNode.children addObject:node.children[i]];
            [node.children[i] setParent:newRightNode];
        }
        // Remove old items from left node, including middle item
        [node.data removeObjectsInRange:NSMakeRange(middle, node.data.count - middle)];
        // Remove old children from left node if exists, including middle
        if (node.children.count) {
            [node.children removeObjectsInRange:NSMakeRange(childIndex, node.children.count - childIndex)];
        }
        // Add to parent, if exists
        if (node.parent) {
            [self addObject:object withChild:newRightNode toNode:node.parent];
        }
        else if (node == self.root)    // Root node, need to create new root
        {
            NSTreeNode *newRootNode = [NSTreeNode new];
            // Set current node's new parent, add as child to new parent
            node.parent = newRootNode;
            [newRootNode.children addObject:node];
            // Set new root
            self.root = newRootNode;
            // Add data and new right branch to new parent
            [self addObject:object withChild:newRightNode toNode:newRootNode];
        }
    }
    // If node is below min capacity (and not the root), need to join
    else if (node != self.root && node.data.count < self.nodeMinimum)
    {
        // If right sibling has more than min elements, rotate left
        if (node.next && node.next.parent == node.parent && node.next.data.count > self.nodeMinimum) {
            [self rotateNode:node toRight:false];
        }
        // If left sibling has more than min elements, rotate right
        else if (node.previous && node.previous.parent == node.parent && node.previous.data.count > self.nodeMinimum) {
            [self rotateNode:node toRight:true];
        }
        // Otherwise, need to merge node with one of its siblings
        else {
            [self mergeSiblingWithNode:node];
        }
    }
    node.changed = true;
}

- (void)rotateNode:(NSTreeNode *)node toRight:(bool)direction
{
    // Can't rotate if no node, no siblings in direction to rotate,
    //  or no data in sibling, or siblings not from same parent
    if (!node || !node.parent || !node.parent.data.count || (!direction && (!node.next || node.next.parent != node.parent || !node.next.data.count)) || (direction && (!node.previous || node.previous.parent != node.parent || !node.previous.data.count))) {
        return;
    }
    // Get index of node in children array of parent
    int indexOfChild = [node.parent indexOfChildNode:node];
    if (indexOfChild == NSNotFound) {
        return;
    }
    // Insert parent data that is next to the node
    int indexOfParentData = indexOfChild - direction;
    int indexOfInsert = (direction ? 0 : node.data.count);
    [node.data insertObject:node.parent.data[indexOfParentData] atIndex:indexOfInsert];
    // Replace parent data with data from sibling
    NSTreeNode *sibling = (direction ? node.previous : node.next);
    int indexOfRemove = (direction ? sibling.data.count - 1 : 0);
    [node.parent.data replaceObjectAtIndex:indexOfParentData withObject:sibling.data[indexOfRemove]];
    [sibling.data removeObjectAtIndex:indexOfRemove];
    // Also move corresponding child of sibling to node if needed
    if (sibling.children.count)
    {
        indexOfRemove += (direction ? 1 : 0);   // +1 if rotating right
        NSTreeNode *child = sibling.children[indexOfRemove];
        // Move to node
        indexOfInsert += (direction ? 0 : 1);   // +1 if rotating left
        [node.children insertObject:child atIndex:indexOfInsert];
        child.parent = node;    // Change parents, but siblings are the same
        // Remove from sibling
        [sibling.children removeObjectAtIndex:indexOfRemove];
    }
    node.changed = true;
    node.parent.changed = true;
    sibling.changed = true;
}

- (void)mergeSiblingWithNode:(NSTreeNode *)node
{
    // Sanity checks: need siblings or node to exist
    if (!node || (!node.previous && !node.next)) {
        return;
    }
    // Setup for merge
    NSTreeNode *leftNode, *rightNode, *parent;
    // Merge with right node if possible
    if (node.next && node.next.parent == node.parent)
    {
        leftNode = node;
        rightNode = node.next;
    }
    // If we can't merge with right node, merge left
    else if (node.previous && node.previous.parent == node.parent)
    {
        leftNode = node.previous;
        rightNode = node;
    }
    // Find index of separator object in parent
    parent = leftNode.parent;
    int index = [parent indexOfChildNode:leftNode];
    // Transfer data & children over from parent / right node
    [leftNode.data addObject:parent.data[index]];
    for (int i = 0; i < rightNode.data.count; ++i) {
        [leftNode.data addObject:rightNode.data[i]];
    }
    for (int i = 0; i < rightNode.children.count; ++i) {
        [leftNode.children addObject:rightNode.children[i]];
        [rightNode.children[i] setParent:leftNode];
    }
    // Clean up parent / right node
    [parent.data removeObjectAtIndex:index];
    [parent.children removeObjectAtIndex:index + 1];
    leftNode.next = rightNode.next;
    if (rightNode.next) {
        rightNode.next.previous = leftNode;
    }
    rightNode.next = rightNode.previous = rightNode.parent = nil;
    [rightNode.children removeAllObjects];
    [rightNode.data removeAllObjects];
    // Rebalance parent if needed
    if (parent.data.count < self.nodeMinimum)
    {
        // If parent is empty root, make leftNode new root
        if (parent == self.root && parent.data.count == 0)
        {
            parent.previous = parent.next = parent.parent = nil;
            [parent.children removeAllObjects];
            leftNode.parent = nil;
            self.root = leftNode;
        }
        else {
            [self rebalanceNode:parent];
        }
    }
    leftNode.changed = true;
    parent.changed = true;
    rightNode.changed = true;
}

@end
