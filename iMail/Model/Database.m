//
//  Database.m
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "Database.h"

@implementation Database

@synthesize db = _db;

- (NSString*)pathOfDatabase:(NSString*)name
{
    NSString* db = [NSString stringWithFormat:@"%@.sqlite3", name];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    NSString* path = [docDir stringByAppendingPathComponent:db];
    return path;
}

- (id)init
{
    if (!(self = [super init])) return nil;
    [self open];
    return self;
}

- (bool)open
{
    NSString* path = [self pathOfDatabase: @"iMail"];
    int result = sqlite3_open([path UTF8String], &_db);
    if (result != SQLITE_OK) {
        return false;
    }
    char *error;
    sqlite3_exec(_db, [@"create table if not exists person (id integer not null primary key autoincrement, name text not null)" UTF8String], 0, 0, &error);
    sqlite3_exec(_db, [@"create table if not exists phone (person_id integer not null, number text not null, unique(person_id, number))" UTF8String], 0, 0, &error);
    sqlite3_exec(_db, [@"create index if not exists phone_id on phone (person_id)" UTF8String], 0, 0, &error);
    sqlite3_exec(_db, [@"create table if not exists email (person_id integer not null, email text not null, unique(person_id, email))" UTF8String], 0, 0, &error);
    sqlite3_exec(_db, [@"create index if not exists email_id on email (person_id)" UTF8String], 0, 0, &error);
    return true;
}

- (void)close
{
    sqlite3_close(_db);
}

- (void)reset
{
    sqlite3_exec(_db, [@"delete from cost" UTF8String], 0, 0, 0);
}


@end
