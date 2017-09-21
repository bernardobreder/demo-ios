//
//  ServiceLocator.m
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "ServiceLocator.h"


@interface ServiceLocator ()

@end

@implementation ServiceLocator

@synthesize contact = _contact;

- (id)initWithDatabase:(Database*)database
{
    if (!(self = [super init])) return nil;
    _contact = [[ContactDB alloc] initWithDatabase:database];
    return self;
}

@end
