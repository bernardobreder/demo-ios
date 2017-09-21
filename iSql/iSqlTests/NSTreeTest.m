//
//  iSqlTests.m
//  iSqlTests
//
//  Created by Bernardo Breder on 31/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSTree.h"

@interface iSqlTests : XCTestCase

@end

@implementation iSqlTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddOne
{
    NSInteger max = 1024;
    NSTree *tree = [[NSTree alloc] init];
    NSNull *nullValue = [NSNull null];
    for (NSInteger n = 0 ; n < max ; n++) {
        [tree add:n value:nullValue];
    }
    for (NSInteger n = 0 ; n < max ; n++) {
        NSNull *value = (NSNull*)[tree get:n];
        XCTAssertNotNil(value);
        XCTAssertTrue(value == nullValue);
    }
}

- (void)testAddTwo
{
    {
        NSTree *tree = [[NSTree alloc] init];
        XCTAssertTrue([tree add:10 value:[NSNumber numberWithInt:10]]);
        XCTAssertTrue([tree add:20 value:[NSNumber numberWithInt:20]]);
    }
    {
        NSTree *tree = [[NSTree alloc] init];
        XCTAssertTrue([tree add:20 value:[NSNumber numberWithInt:20]]);
        XCTAssertTrue([tree add:10 value:[NSNumber numberWithInt:10]]);
    }
}

- (void)testClear
{
    NSTree *tree = [[NSTree alloc] init];
    NSInteger max = 1024;
    //    for (;;) {
    @autoreleasepool {
        for (NSInteger n = 0 ; n < max ; n++) {
            [tree add:n value:[NSNumber numberWithInteger:n]];
        }
        for (NSInteger n = 0 ; n < max ; n++) {
            XCTAssertNotNil([tree get:n]);
        }
        [tree clear];
        for (NSInteger n = 0 ; n < max ; n++) {
            XCTAssertNil([tree get:n]);
        }
    }
    //    }
}

- (void)testRemoveAll
{
    NSTree *tree = [[NSTree alloc] init];
    NSInteger max = 1024;
    //    for (;;) {
    @autoreleasepool {
        for (NSInteger n = 0 ; n < max ; n++) {
            [tree add:n value:[NSNumber numberWithInteger:n]];
        }
        for (NSInteger n = 0 ; n < max ; n++) {
            XCTAssertNotNil([tree get:n]);
        }
        for (NSInteger n = 0 ; n < max ; n++) {
            XCTAssertTrue([tree remove:n]);
        }
        for (NSInteger n = 0 ; n < max ; n++) {
            XCTAssertNil([tree get:n]);
        }
    }
    //    }
}

- (void)testIterator
{
    NSTree *tree = [[NSTree alloc] init];
    [tree add:10 value:[NSNumber numberWithInt:10]];
    [tree add:5 value:[NSNumber numberWithInt:5]];
    [tree add:3 value:[NSNumber numberWithInt:3]];
    [tree add:4 value:[NSNumber numberWithInt:4]];
    [tree add:6 value:[NSNumber numberWithInt:6]];
    [tree add:1 value:[NSNumber numberWithInt:1]];
    [tree add:8 value:[NSNumber numberWithInt:8]];
    XCTAssertEqual(7, tree.size);
    XCTAssertEqual(1, [tree first].key);
    XCTAssertEqual(3, [[tree first] next].key);
    XCTAssertEqual(4, [[[tree first] next] next].key);
    XCTAssertEqual(5, [[[[tree first] next] next] next].key);
    XCTAssertEqual(6, [[[[[tree first] next] next] next] next].key);
    XCTAssertEqual(8, [[[[[[tree first] next] next] next] next] next].key);
    XCTAssertEqual(10, [[[[[[[tree first] next] next] next] next] next] next].key);
    XCTAssertNil([[[[[[[[tree first] next] next] next] next] next] next] next]);
}

@end
