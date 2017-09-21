//
//  ContactDB.m
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "ContactDB.h"

@interface ContactDB ()

@property (nonatomic, strong) Database *database;

@end

@implementation ContactDB

@synthesize database = _database;

- (id)initWithDatabase:(Database*)database
{
    if (!(self = [super init])) return nil;
    _database = database;
    return self;
}

- (Contact*)get:(NSInteger)Id
{
    NSString* sql = @"select id, name from person where id = ?";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return 0;
    }
    Contact* data = 0;
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        data = [[Contact alloc] init];
        data.Id = sqlite3_column_int(stmt, 0);
        data.name = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
    }
    sqlite3_finalize(stmt);
    return data;
}

- (NSArray*)list
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSString* sql = @"select id, name from person";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return 0;
    }
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Contact *data = [[Contact alloc] init];
        data.Id = sqlite3_column_int(stmt, 0);
        data.name = [NSString stringWithCString:(const char*)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
        [array addObject:data];
    }
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        [array removeAllObjects];
        return 0;
    }
    sqlite3_finalize(stmt);
    return array;

}

- (bool)update:(NSInteger)Id name:(NSString*)name
{
    NSString* sql = @"update person set name = ? where id = ?";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_text(stmt, 1, [name UTF8String], -1, nil);
    sqlite3_bind_int(stmt, 2, (int)Id);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

- (bool)addPhone:(NSInteger)Id phone:(NSString*)phone
{
    NSString* sql = @"insert or replace into phone (person_id, number) values (?, ?)";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_int(stmt, 1, (int)Id);
    sqlite3_bind_text(stmt, 2, [phone UTF8String], -1, nil);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

- (bool)removePhone:(NSInteger)Id phone:(NSString*)phone
{
    NSString* sql = @"delete from phone where person_id = ? and number = ?";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_int(stmt, 1, (int)Id);
    sqlite3_bind_text(stmt, 2, [phone UTF8String], -1, nil);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

- (bool)addEmail:(NSInteger)Id email:(NSString*)email
{
    NSString* sql = @"insert or replace into email (person_id, email) values (?, ?)";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_int(stmt, 1, (int)Id);
    sqlite3_bind_text(stmt, 2, [email UTF8String], -1, nil);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

- (bool)removeEmail:(NSInteger)Id email:(NSString*)email
{
    NSString* sql = @"delete from email where person_id = ? and email = ?";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_int(stmt, 1, (int)Id);
    sqlite3_bind_text(stmt, 2, [email UTF8String], -1, nil);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

- (bool)remove:(NSInteger)Id
{
    NSString* sql = @"delete from person where id = ?";
    sqlite3_stmt* stmt;
    int result = sqlite3_prepare_v2(_database.db, [sql UTF8String], -1, &stmt, 0);
    if (result != SQLITE_OK) {
        return false;
    }
    sqlite3_bind_int(stmt, 1, (int)Id);
    result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        sqlite3_finalize(stmt);
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

@end
