//
//  NSReaderData.m
//  iSql
//
//  Created by Bernardo Breder on 14/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "NSData+Reader.h"

@implementation NSData (NSReaderData)

#define NULL_TYPE 1
#define BOOL_TYPE 2
#define BYTE_TYPE 3
#define UBYTE_TYPE 4
#define INT_TYPE 5
#define UINT_TYPE 6
#define INT64_TYPE 7
#define UINT64_TYPE 8
#define STR_TYPE 9
#define DATA_TYPE 10
#define DIC_TYPE 11
#define ARRAY_TYPE 12
#define ARRAY_UINT64_TYPE 13

- (bool)isNull:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == NULL_TYPE;
}

- (bool)isBoolean:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == BOOL_TYPE;
}

- (bool)isByte:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == BYTE_TYPE;
}

- (bool)isUByte:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == UBYTE_TYPE;
}

- (bool)isInteger:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == INT_TYPE;
}

- (bool)isUInteger:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == UINT_TYPE;
}

- (bool)isInteger64:(int64_t)offset
{
    return ((unsigned char *)[self bytes])[offset] == INT64_TYPE;
}

- (bool)isUInteger64:(uint64_t)offset
{
    return ((unsigned char *)[self bytes])[offset] == UINT64_TYPE;
}

- (bool)isString:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == STR_TYPE;
}

- (bool)isDataWithSize:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == DATA_TYPE;
}

- (bool)isArray:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == ARRAY_TYPE;
}

- (bool)isDictionary:(NSUInteger)offset
{
    return ((unsigned char *)[self bytes])[offset] == DIC_TYPE;
}

- (bool)isUInteger64Array:(uint64_t)offset
{
	return ((unsigned char *)[self bytes])[offset] == ARRAY_UINT64_TYPE;
}

- (NSNull*)readNull:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != NULL_TYPE) {
        return false;
    }
    *offset += 1;
    return [NSNull null];
}

- (bool)readBoolean:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != BOOL_TYPE) {
        return false;
    }
    *offset += 2;
    return *bytes != 0;
}

- (int8_t)readByte:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != BYTE_TYPE) {
        return 0;
    }
    unsigned char a = *bytes++;
    *offset += 2;
    if ((a & 0x80) == 0x80) {
        a -= 0x80;
        return -a;
    } else {
        return a;
    }
}

- (uint8_t)readUByte:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != UBYTE_TYPE) {
        return 0;
    }
    *offset += 2;
    return *bytes++;
}

- (int32_t)readInteger32:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != INT_TYPE) {
        return 0;
    }
    int32_t a = *bytes++;
    int32_t b = *bytes++;
    int32_t c = *bytes++;
    int32_t d = *bytes++;
    *offset += 5;
    if ((a & 0x80) == 0x80) {
        a -= 0x80;
        return -((a << 24) + (b << 16) + (c << 8) + d);
    } else {
        return (a << 24) + (b << 16) + (c << 8) + d;
    }
}

- (uint32_t)readUInteger32:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != UINT_TYPE) {
        return 0;
    }
    uint32_t a = *bytes++;
    uint32_t b = *bytes++;
    uint32_t c = *bytes++;
    uint32_t d = *bytes++;
    *offset += 5;
    return (a << 24) + (b << 16) + (c << 8) + d;
}

- (int64_t)readInteger64:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != INT64_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    if ((a & 0x80) == 0x80) {
        a -= 0x80;
        return -((a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h);
    } else {
        return (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
    }
}

- (uint64_t)readUInteger64:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != UINT64_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    return (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
}

- (NSString*)readString:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != STR_TYPE) {
        return 0;
    }
    int32_t a = *bytes++;
    int32_t b = *bytes++;
    int32_t c = *bytes++;
    int32_t d = *bytes++;
    *offset += 5;
    NSUInteger length = (a << 24) + (b << 16) + (c << 8) + d;
    char buffer[length+1];
    buffer[length] = 0;
    strncpy(buffer, (char*)bytes, length);
    *offset += length;
    return [NSString stringWithUTF8String:buffer];
}

- (NSMutableArray*)readArray:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != ARRAY_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    uint64_t length64 = (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
    if (sizeof(NSInteger) == sizeof(int)) {
        if (length64 > INT32_MAX) {
            return nil;
        }
    }
    NSUInteger length = (NSUInteger)length64;
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:length];
    for (NSUInteger n = 0 ; n < length ; n++) {
        NSObject *obj = [self readObject:offset];
        [data addObject:obj];
    }
    return data;
}

- (NSMutableArray*)readUInteger64Array:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != ARRAY_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    uint64_t length64 = (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
    if (sizeof(NSInteger) == sizeof(int)) {
        if (length64 > INT32_MAX) {
            return nil;
        }
    }
    NSUInteger length = (NSUInteger)length64;
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:length];
    for (NSUInteger n = 0 ; n < length ; n++) {
		a = *bytes++;
		b = *bytes++;
		c = *bytes++;
		d = *bytes++;
		e = *bytes++;
		f = *bytes++;
		g = *bytes++;
		h = *bytes++;
		uint64_t value = (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
        [data addObject:[NSNumber numberWithUnsignedLongLong:value]];
    }
    return data;
}

- (NSMutableDictionary*)readDictionary:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != DIC_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    uint64_t length64 = (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
    if (sizeof(NSInteger) == sizeof(int)) {
        if (length64 > INT32_MAX) {
            return nil;
        }
    }
    NSUInteger length = (NSUInteger)length64;
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:length];
    for (NSUInteger n = 0 ; n < length ; n++) {
        id<NSCopying> key = [self readNSCopying:offset];
        NSObject *obj = [self readObject:offset];
        [data setObject:obj forKey:key];
    }
    return data;
}

- (NSData*)readDataWithSize:(NSUInteger*)offset
{
    unsigned char *bytes = (unsigned char *)[self bytes] + *offset;
    if (*bytes++ != DATA_TYPE) {
        return 0;
    }
    uint64_t a = *bytes++;
    uint64_t b = *bytes++;
    uint64_t c = *bytes++;
    uint64_t d = *bytes++;
    uint32_t e = *bytes++;
    uint32_t f = *bytes++;
    uint32_t g = *bytes++;
    uint32_t h = *bytes++;
    *offset += 9;
    uint64_t length64 = (a << 56) + (b << 48) + (c << 40) + (d << 32) + (e << 24) + (f << 16) + (g << 8) + h;
    if (sizeof(NSInteger) == sizeof(int)) {
        if (length64 > INT32_MAX) {
            return nil;
        }
    }
    NSUInteger length = (NSUInteger)length64;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length];
    [data appendBytes:bytes length:length];
    *offset += length;
    return data;
}

- (NSObject*)readObject:(NSUInteger*)offset
{
    switch (((uint8_t*)[self bytes])[*offset]) {
        case UINT_TYPE:
            return [NSNumber numberWithUnsignedInteger:[self readUInteger32:offset]];
        case INT_TYPE:
            return [NSNumber numberWithInt:[self readInteger32:offset]];
        case UBYTE_TYPE:
            return [NSNumber numberWithUnsignedChar:[self readUByte:offset]];
        case BYTE_TYPE:
            return [NSNumber numberWithChar:[self readByte:offset]];
        case UINT64_TYPE:
            return [NSNumber numberWithLongLong:[self readUInteger64:offset]];
        case INT64_TYPE:
            return [NSNumber numberWithLongLong:[self readInteger64:offset]];
        case STR_TYPE:
            return [self readString:offset];
        case ARRAY_TYPE:
            return [self readArray:offset];
        case DIC_TYPE:
            return [self readDictionary:offset];
        case DATA_TYPE:
            return [self readDataWithSize:offset];
        case NULL_TYPE:
            return [NSNull null];
        default:
            return [NSNull null];
    }
}

- (id<NSCopying>)readNSCopying:(NSUInteger*)offset
{
    switch (((uint8_t*)[self bytes])[*offset]) {
        case UINT_TYPE:
            return [NSNumber numberWithUnsignedInteger:[self readUInteger32:offset]];
        case INT_TYPE:
            return [NSNumber numberWithInt:[self readInteger32:offset]];
        case UBYTE_TYPE:
            return [NSNumber numberWithUnsignedChar:[self readUByte:offset]];
        case BYTE_TYPE:
            return [NSNumber numberWithChar:[self readByte:offset]];
        case UINT64_TYPE:
            return [NSNumber numberWithLongLong:[self readUInteger64:offset]];
        case INT64_TYPE:
            return [NSNumber numberWithLongLong:[self readInteger64:offset]];
        case STR_TYPE:
            return [self readString:offset];
        case ARRAY_TYPE:
            return [self readArray:offset];
        case DIC_TYPE:
            return [self readDictionary:offset];
        case DATA_TYPE:
            return [self readDataWithSize:offset];
        case NULL_TYPE:
            return [NSNull null];
        default:
            return [NSNull null];
    }
}

@end

@implementation NSMutableData (NSWriterData)

- (void)appendBoolean:(bool)value
{
    unsigned char buffer[2];
    buffer[0] = BOOL_TYPE;
    buffer[1] = value ? 1 : 0;
    [self appendBytes:buffer length:2];
}

- (void)appendByte:(int8_t)value
{
    unsigned char buffer[2];
    buffer[0] = BYTE_TYPE;
    buffer[1] = value & 0xFF;
    [self appendBytes:buffer length:2];
}

- (void)appendUByte:(uint8_t)value;
{
    unsigned char buffer[2];
    buffer[0] = UBYTE_TYPE;
    buffer[1] = value & 0xFF;
    [self appendBytes:buffer length:2];
}

- (void)appendInteger:(NSInteger)value
{
    unsigned char buffer[5];
    buffer[0] = INT_TYPE;
    buffer[1] = (value >> 24) & 0xFF;
    buffer[2] = (value >> 16) & 0xFF;
    buffer[3] = (value >> 8) & 0xFF;
    buffer[4] = (value >> 0) & 0xFF;
    if (value < 0) {
        buffer[1] += 0x80;
    }
    [self appendBytes:buffer length:5];
}

- (void)appendUInteger:(NSUInteger)value
{
    unsigned char buffer[5];
    buffer[0] = UINT_TYPE;
    buffer[1] = (value >> 24) & 0xFF;
    buffer[2] = (value >> 16) & 0xFF;
    buffer[3] = (value >> 8) & 0xFF;
    buffer[4] = (value >> 0) & 0xFF;
    [self appendBytes:buffer length:5];
}

- (void)appendInteger64:(int64_t)value
{
    unsigned char buffer[9];
    buffer[0] = INT64_TYPE;
    buffer[1] = (value >> 56) & 0xFF;
    buffer[2] = (value >> 48) & 0xFF;
    buffer[3] = (value >> 40) & 0xFF;
    buffer[4] = (value >> 32) & 0xFF;
    buffer[5] = (value >> 24) & 0xFF;
    buffer[6] = (value >> 16) & 0xFF;
    buffer[7] = (value >> 8) & 0xFF;
    buffer[8] = (value >> 0) & 0xFF;
    if (value < 0) {
        buffer[1] += 0x80;
    }
    [self appendBytes:buffer length:9];
}

- (void)appendUInteger64:(uint64_t)value
{
    unsigned char buffer[9];
    buffer[0] = UINT64_TYPE;
    buffer[1] = (value >> 56) & 0xFF;
    buffer[2] = (value >> 48) & 0xFF;
    buffer[3] = (value >> 40) & 0xFF;
    buffer[4] = (value >> 32) & 0xFF;
    buffer[5] = (value >> 24) & 0xFF;
    buffer[6] = (value >> 16) & 0xFF;
    buffer[7] = (value >> 8) & 0xFF;
    buffer[8] = (value >> 0) & 0xFF;
    [self appendBytes:buffer length:9];
}


- (void)appendString:(NSString*)value
{
    NSUInteger length = value.length;
    unsigned char buffer[5];
    buffer[0] = STR_TYPE;
    buffer[1] = (length >> 24) & 0xFF;
    buffer[2] = (length >> 16) & 0xFF;
    buffer[3] = (length >> 8) & 0xFF;
    buffer[4] = (length >> 0) & 0xFF;
    [self appendBytes:buffer length:5];
    [self appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendDataWithSize:(NSData*)value
{
    uint64_t length = value.length;
    unsigned char buffer[9];
    buffer[0] = DATA_TYPE;
    buffer[1] = (length >> 56) & 0xFF;
    buffer[2] = (length >> 48) & 0xFF;
    buffer[3] = (length >> 40) & 0xFF;
    buffer[4] = (length >> 32) & 0xFF;
    buffer[5] = (length >> 24) & 0xFF;
    buffer[6] = (length >> 16) & 0xFF;
    buffer[7] = (length >> 8) & 0xFF;
    buffer[8] = (length >> 0) & 0xFF;
    [self appendBytes:buffer length:9];
    [self appendData:value];
}

- (void)appendArray:(NSArray*)value
{
    uint64_t length = value.count;
    unsigned char buffer[9];
    buffer[0] = ARRAY_TYPE;
    buffer[1] = (length >> 56) & 0xFF;
    buffer[2] = (length >> 48) & 0xFF;
    buffer[3] = (length >> 40) & 0xFF;
    buffer[4] = (length >> 32) & 0xFF;
    buffer[5] = (length >> 24) & 0xFF;
    buffer[6] = (length >> 16) & 0xFF;
    buffer[7] = (length >> 8) & 0xFF;
    buffer[8] = (length >> 0) & 0xFF;
    [self appendBytes:buffer length:9];
    for (NSUInteger n = 0 ; n < value.count ; n++) {
        [self appendNSObject:value[n]];
    }
}

- (void)appendUInteger64Array:(NSArray*)value
{
    uint64_t length = value.count;
    unsigned char buffer[9];
    buffer[0] = ARRAY_UINT64_TYPE;
    buffer[1] = (length >> 56) & 0xFF;
    buffer[2] = (length >> 48) & 0xFF;
    buffer[3] = (length >> 40) & 0xFF;
    buffer[4] = (length >> 32) & 0xFF;
    buffer[5] = (length >> 24) & 0xFF;
    buffer[6] = (length >> 16) & 0xFF;
    buffer[7] = (length >> 8) & 0xFF;
    buffer[8] = (length >> 0) & 0xFF;
    [self appendBytes:buffer length:9];
    for (NSUInteger n = 0 ; n < value.count ; n++) {
		uint64_t value64 = [value[n] unsignedLongLongValue];
		buffer[0] = (value64 >> 56) & 0xFF;
		buffer[1] = (value64 >> 48) & 0xFF;
		buffer[2] = (value64 >> 40) & 0xFF;
		buffer[3] = (value64 >> 32) & 0xFF;
		buffer[4] = (value64 >> 24) & 0xFF;
		buffer[5] = (value64 >> 16) & 0xFF;
		buffer[6] = (value64 >> 8) & 0xFF;
		buffer[7] = (value64 >> 0) & 0xFF;
    }
}

- (void)appendDictionary:(NSDictionary*)value
{
    uint64_t length = value.count;
    unsigned char buffer[9];
    buffer[0] = DIC_TYPE;
    buffer[1] = (length >> 56) & 0xFF;
    buffer[2] = (length >> 48) & 0xFF;
    buffer[3] = (length >> 40) & 0xFF;
    buffer[4] = (length >> 32) & 0xFF;
    buffer[5] = (length >> 24) & 0xFF;
    buffer[6] = (length >> 16) & 0xFF;
    buffer[7] = (length >> 8) & 0xFF;
    buffer[8] = (length >> 0) & 0xFF;
    [self appendBytes:buffer length:9];
    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[self appendNSObject:key];
		[self appendNSObject:obj];
    }];
}

- (void)appendNull
{
    unsigned char buffer[1];
    buffer[0] = NULL_TYPE;
    [self appendBytes:buffer length:1];
}

- (void)appendNSObject:(NSObject*)value
{
    if (value == [NSNull null]) {
        [self appendNull];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber*)value;
        const char *type = [number objCType];
        switch (type[0]) {
            case 'i':
                [self appendInteger:[number intValue]];
                break;
            case 'q':
                [self appendInteger64:[number longLongValue]];
                break;
            default:
                [self appendInteger:0];
                break;
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *string = (NSString*)value;
        [self appendString:string];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)value;
        [self appendArray:array];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)value;
        [self appendDictionary:dic];
    } else if ([value isKindOfClass:[NSData class]]) {
        NSData *data = (NSData*)value;
        [self appendDataWithSize:data];
    }
}

@end