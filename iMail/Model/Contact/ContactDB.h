//
//  ContactDB.h
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface ContactDB : NSObject

- (id)initWithDatabase:(Database*)database;

- (Contact*)get:(NSInteger)Id;

- (NSArray*)list;

- (bool)update:(NSInteger)Id name:(NSString*)name;

- (bool)addPhone:(NSInteger)Id phone:(NSString*)phone;

- (bool)removePhone:(NSInteger)Id phone:(NSString*)phone;

- (bool)addEmail:(NSInteger)Id email:(NSString*)email;

- (bool)removeEmail:(NSInteger)Id email:(NSString*)email;

- (bool)remove:(NSInteger)Id;

@end
