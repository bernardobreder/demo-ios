//
//  MyDocument.m
//  iSampleDocument
//
//  Created by Bernardo Breder on 25/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "MyDocument.h"

@interface MyDocument ()

@property (nonatomic, strong) NSFileWrapper * fileWrapper;

@end

@implementation MyDocument

- (void)encodeObject:(id<NSCoding>)object toWrappers:(NSMutableDictionary *)wrappers preferredFilename:(NSString *)preferredFilename {
    @autoreleasepool {
        NSMutableData * data = [NSMutableData data];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:@"data"];
        [archiver finishEncoding];
        NSFileWrapper * wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (self.metadata == nil || self.data == nil) {
        return nil;
    }
    NSMutableDictionary * wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:self.metadata toWrappers:wrappers preferredFilename:METADATA_FILENAME];
    [self encodeObject:self.data toWrappers:wrappers preferredFilename:DATA_FILENAME];
    NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    return fileWrapper;
}

- (id)decodeObjectFromWrapperWithPreferredFilename:(NSString *)preferredFilename {
    NSFileWrapper * fileWrapper = [self.fileWrapper.fileWrappers objectForKey:preferredFilename];
    if (!fileWrapper) {
        NSLog(@"Unexpected error: Couldn't find %@ in file wrapper!", preferredFilename);
        return nil;
    }
    NSData * data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    return [unarchiver decodeObjectForKey:@"data"];
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    self.fileWrapper = (NSFileWrapper *) contents;
    
    // The rest will be lazy loaded...
    self.data = nil;
    self.metadata = nil;
    
    return YES;
    
}

@end
