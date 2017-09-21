//
//  NSReaderData.h
//  iSql
//
//  Created by Bernardo Breder on 14/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

@interface NSData (NSReaderData)

- (bool)isNull:(NSUInteger)offset;

- (bool)isBoolean:(NSUInteger)offset;

- (bool)isInteger:(NSUInteger)offset;

- (bool)isUInteger:(NSUInteger)offset;

- (bool)isInteger64:(int64_t)offset;

- (bool)isUInteger64:(uint64_t)offset;

- (bool)isString:(NSUInteger)offset;

- (bool)isDataWithSize:(NSUInteger)offset;

- (bool)isArray:(NSUInteger)offset;

- (bool)isDictionary:(NSUInteger)offset;

- (bool)isUInteger64Array:(uint64_t)offset;

- (NSNull*)readNull:(NSUInteger*)offset;

- (bool)readBoolean:(NSUInteger*)offset;

- (int8_t)readByte:(NSUInteger*)offset;

- (uint8_t)readUByte:(NSUInteger*)offset;

- (int32_t)readInteger32:(NSUInteger*)offset;

- (uint32_t)readUInteger32:(NSUInteger*)offset;

- (int64_t)readInteger64:(NSUInteger*)offset;

- (uint64_t)readUInteger64:(NSUInteger*)offset;

- (NSString*)readString:(NSUInteger*)offset;

- (NSData*)readDataWithSize:(NSUInteger*)offset;

- (NSMutableArray*)readArray:(NSUInteger*)offset;

- (NSMutableArray*)readUInteger64Array:(NSUInteger*)offset;

- (NSMutableDictionary*)readDictionary:(NSUInteger*)offset;

- (NSObject*)readObject:(NSUInteger*)offset;

- (id<NSCopying>)readNSCopying:(NSUInteger*)offset;

@end

@interface NSMutableData (NSWriterData)

- (void)appendBoolean:(bool)value;

- (void)appendByte:(int8_t)value;

- (void)appendUByte:(uint8_t)value;

- (void)appendInteger:(NSInteger)value;

- (void)appendUInteger:(NSUInteger)value;

- (void)appendInteger64:(int64_t)value;

- (void)appendUInteger64:(uint64_t)value;

- (void)appendString:(NSString*)value;

- (void)appendDataWithSize:(NSData*)value;

- (void)appendNull;

- (void)appendArray:(NSArray*)value;

- (void)appendUInteger64Array:(NSArray*)value;

- (void)appendDictionary:(NSDictionary*)value;

- (void)appendNSObject:(NSObject*)value;

@end
