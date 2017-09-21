//
//  ServiceLocator.h
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface ServiceLocator : NSObject

@property (nonatomic, strong) ContactDB *contact;

- (id)initWithDatabase:(Database*)database;

@end
