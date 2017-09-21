//
//  NSTreeStorage.h
//  iSql
//
//  Created by Bernardo Breder on 14/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface NSTreeStorage : NSObject

- (id)initWithName:(NSString*)name;

- (void)addTree:(NSTree*)tree withName:(NSString*)name;

- (NSTree*)getInTree:(NSString*)name indexAt:(NSInteger)id;

- (bool)commit;

- (void)rollback;

+ (void)clear;

@end
