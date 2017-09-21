//
//  Database.h
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface Database : NSObject

@property (nonatomic, assign) sqlite3* db;

- (bool)open;

- (void)close;

@end
