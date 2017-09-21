//
//  Contact.h
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface Contact : NSObject

@property (nonatomic, assign) NSInteger Id;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSMutableArray *phones;

@property (nonatomic, strong) NSMutableArray *emails;

@end
