//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSTreeStorageTest : XCTestCase

@end

@implementation NSTreeStorageTest

- (void)setUp
{
    [super setUp];
    [NSTreeStorage clear];
}

- (void)tearDown
{
    [super tearDown];
    [NSTreeStorage clear];
}

#if false
- (void)testMarkChanged
{
    NSTree *tree = [[NSTree alloc] init];
    {
        XCTAssertFalse(tree.changed);
        XCTAssertNil(tree.root);
        [tree add:10 value:[NSNumber numberWithInt:10]];
        XCTAssertTrue(tree.changed);
        XCTAssertTrue(tree.root.changed);
        XCTAssertEqual(10, tree.root.key);
        XCTAssertEqual(10, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNil(tree.root.left);
        XCTAssertNil(tree.root.right);
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
    }
    {
        [tree add:5 value:[NSNumber numberWithInt:5]];
        XCTAssertTrue(tree.changed);
        XCTAssertTrue(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNil(tree.root.left);
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertTrue(tree.root.right.changed);
            XCTAssertEqual(10, tree.root.right.key);
            XCTAssertEqual(10, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNil(tree.root.right.left);
            XCTAssertNil(tree.root.right.right);
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
    }
    {
        [tree add:3 value:[NSNumber numberWithInt:3]];
        XCTAssertTrue(tree.changed);
        XCTAssertTrue(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNotNil(tree.root.left);
        {
            XCTAssertTrue(tree.root.left.changed);
            XCTAssertEqual(3, tree.root.left.key);
            XCTAssertEqual(3, [((NSNumber*)tree.root.left.value) intValue]);
            XCTAssertNil(tree.root.left.left);
            XCTAssertNil(tree.root.left.right);
            XCTAssertEqual(tree.root, tree.root.left.parent);
        }
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertFalse(tree.root.right.changed);
            XCTAssertEqual(10, tree.root.right.key);
            XCTAssertEqual(10, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNil(tree.root.right.left);
            XCTAssertNil(tree.root.right.right);
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
        XCTAssertFalse(tree.root.left.changed);
    }
    {
        [tree add:4 value:[NSNumber numberWithInt:4]];
        XCTAssertTrue(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNotNil(tree.root.left);
        {
            XCTAssertTrue(tree.root.left.changed);
            XCTAssertEqual(3, tree.root.left.key);
            XCTAssertEqual(3, [((NSNumber*)tree.root.left.value) intValue]);
            XCTAssertNil(tree.root.left.left);
            XCTAssertNotNil(tree.root.left.right);
            {
                XCTAssertTrue(tree.root.left.right.changed);
                XCTAssertEqual(4, tree.root.left.right.key);
                XCTAssertEqual(4, [((NSNumber*)tree.root.left.right.value) intValue]);
                XCTAssertNil(tree.root.left.right.left);
                XCTAssertNil(tree.root.left.right.right);
                XCTAssertEqual(tree.root.left, tree.root.left.right.parent);
            }
            XCTAssertEqual(tree.root, tree.root.left.parent);
        }
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertFalse(tree.root.right.changed);
            XCTAssertEqual(10, tree.root.right.key);
            XCTAssertEqual(10, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNil(tree.root.right.left);
            XCTAssertNil(tree.root.right.right);
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
        XCTAssertFalse(tree.root.left.changed);
        XCTAssertFalse(tree.root.left.right.changed);
    }
    {
        [tree add:6 value:[NSNumber numberWithInt:6]];
        XCTAssertTrue(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNotNil(tree.root.left);
        {
            XCTAssertFalse(tree.root.left.changed);
            XCTAssertEqual(3, tree.root.left.key);
            XCTAssertEqual(3, [((NSNumber*)tree.root.left.value) intValue]);
            XCTAssertNil(tree.root.left.left);
            XCTAssertNotNil(tree.root.left.right);
            {
                XCTAssertFalse(tree.root.left.right.changed);
                XCTAssertEqual(4, tree.root.left.right.key);
                XCTAssertEqual(4, [((NSNumber*)tree.root.left.right.value) intValue]);
                XCTAssertNil(tree.root.left.right.left);
                XCTAssertNil(tree.root.left.right.right);
                XCTAssertEqual(tree.root.left, tree.root.left.right.parent);
            }
            XCTAssertEqual(tree.root, tree.root.left.parent);
        }
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertTrue(tree.root.right.changed);
            XCTAssertEqual(10, tree.root.right.key);
            XCTAssertEqual(10, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNotNil(tree.root.right.left);
            {
                XCTAssertTrue(tree.root.right.left.changed);
                XCTAssertEqual(6, tree.root.right.left.key);
                XCTAssertEqual(6, [((NSNumber*)tree.root.right.left.value) intValue]);
                XCTAssertNil(tree.root.right.left.left);
                XCTAssertNil(tree.root.right.left.right);
                XCTAssertEqual(tree.root.right, tree.root.right.left.parent);
            }
            XCTAssertNil(tree.root.right.right);
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
        XCTAssertFalse(tree.root.left.changed);
        XCTAssertFalse(tree.root.left.right.changed);
        XCTAssertFalse(tree.root.right.left.changed);
    }
    {
        [tree add:1 value:[NSNumber numberWithInt:1]];
        XCTAssertTrue(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNotNil(tree.root.left);
        {
            XCTAssertTrue(tree.root.left.changed);
            XCTAssertEqual(3, tree.root.left.key);
            XCTAssertEqual(3, [((NSNumber*)tree.root.left.value) intValue]);
            XCTAssertNotNil(tree.root.left.left);
            {
                XCTAssertTrue(tree.root.left.left.changed);
                XCTAssertEqual(1, tree.root.left.left.key);
                XCTAssertEqual(1, [((NSNumber*)tree.root.left.left.value) intValue]);
                XCTAssertNil(tree.root.left.left.left);
                XCTAssertNil(tree.root.left.left.right);
                XCTAssertEqual(tree.root.left, tree.root.left.left.parent);
            }
            XCTAssertNotNil(tree.root.left.right);
            {
                XCTAssertFalse(tree.root.left.right.changed);
                XCTAssertEqual(4, tree.root.left.right.key);
                XCTAssertEqual(4, [((NSNumber*)tree.root.left.right.value) intValue]);
                XCTAssertNil(tree.root.left.right.left);
                XCTAssertNil(tree.root.left.right.right);
                XCTAssertEqual(tree.root.left, tree.root.left.right.parent);
            }
            XCTAssertEqual(tree.root, tree.root.left.parent);
        }
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertFalse(tree.root.right.changed);
            XCTAssertEqual(10, tree.root.right.key);
            XCTAssertEqual(10, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNotNil(tree.root.right.left);
            {
                XCTAssertFalse(tree.root.right.left.changed);
                XCTAssertEqual(6, tree.root.right.left.key);
                XCTAssertEqual(6, [((NSNumber*)tree.root.right.left.value) intValue]);
                XCTAssertNil(tree.root.right.left.left);
                XCTAssertNil(tree.root.right.left.right);
                XCTAssertEqual(tree.root.right, tree.root.right.left.parent);
            }
            XCTAssertNil(tree.root.right.right);
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
        XCTAssertFalse(tree.root.left.changed);
        XCTAssertFalse(tree.root.left.left.changed);
        XCTAssertFalse(tree.root.left.right.changed);
        XCTAssertFalse(tree.root.right.left.changed);
    }
    {
        [tree add:8 value:[NSNumber numberWithInt:8]];
        XCTAssertTrue(tree.changed);
        XCTAssertTrue(tree.root.changed);
        XCTAssertEqual(5, tree.root.key);
        XCTAssertEqual(5, [((NSNumber*)tree.root.value) intValue]);
        XCTAssertNotNil(tree.root.left);
        {
            XCTAssertFalse(tree.root.left.changed);
            XCTAssertEqual(3, tree.root.left.key);
            XCTAssertEqual(3, [((NSNumber*)tree.root.left.value) intValue]);
            XCTAssertNotNil(tree.root.left.left);
            {
                XCTAssertFalse(tree.root.left.left.changed);
                XCTAssertEqual(1, tree.root.left.left.key);
                XCTAssertEqual(1, [((NSNumber*)tree.root.left.left.value) intValue]);
                XCTAssertNil(tree.root.left.left.left);
                XCTAssertNil(tree.root.left.left.right);
                XCTAssertEqual(tree.root.left, tree.root.left.left.parent);
            }
            XCTAssertNotNil(tree.root.left.right);
            {
                XCTAssertFalse(tree.root.left.right.changed);
                XCTAssertEqual(4, tree.root.left.right.key);
                XCTAssertEqual(4, [((NSNumber*)tree.root.left.right.value) intValue]);
                XCTAssertNil(tree.root.left.right.left);
                XCTAssertNil(tree.root.left.right.right);
                XCTAssertEqual(tree.root.left, tree.root.left.right.parent);
            }
            XCTAssertEqual(tree.root, tree.root.left.parent);
        }
        XCTAssertNotNil(tree.root.right);
        {
            XCTAssertTrue(tree.root.right.changed);
            XCTAssertEqual(8, tree.root.right.key);
            XCTAssertEqual(8, [((NSNumber*)tree.root.right.value) intValue]);
            XCTAssertNotNil(tree.root.right.left);
            {
                XCTAssertTrue(tree.root.right.left.changed);
                XCTAssertEqual(6, tree.root.right.left.key);
                XCTAssertEqual(6, [((NSNumber*)tree.root.right.left.value) intValue]);
                XCTAssertNil(tree.root.right.left.left);
                XCTAssertNil(tree.root.right.left.right);
                XCTAssertEqual(tree.root.right, tree.root.right.left.parent);
            }
            XCTAssertNotNil(tree.root.right.right);
            {
                XCTAssertTrue(tree.root.right.right.changed);
                XCTAssertEqual(10, tree.root.right.right.key);
                XCTAssertEqual(10, [((NSNumber*)tree.root.right.right.value) intValue]);
                XCTAssertNil(tree.root.right.right.left);
                XCTAssertNil(tree.root.right.right.right);
                XCTAssertEqual(tree.root.right, tree.root.right.right.parent);
            }
            XCTAssertEqual(tree.root, tree.root.right.parent);
        }
        XCTAssertNil(tree.root.parent);
        [tree unmarkChanged];
        XCTAssertFalse(tree.changed);
        XCTAssertFalse(tree.root.changed);
        XCTAssertFalse(tree.root.right.changed);
        XCTAssertFalse(tree.root.left.changed);
        XCTAssertFalse(tree.root.left.left.changed);
        XCTAssertFalse(tree.root.left.right.changed);
        XCTAssertFalse(tree.root.right.left.changed);
        XCTAssertFalse(tree.root.right.right.changed);
    }
}
#endif

@end
