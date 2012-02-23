//
// ImageCache.h
// Copyright (C) 2012  Alan SCHNEIDER
//                     <contact@shkschneider.me>
//
// This program comes with ABSOLUTELY NO WARRANTY.
// This is free software, and you are welcome to redistribute it
// under certain conditions.
//

#import <Foundation/Foundation.h>

#define IMAGE_CACHE_CAPACITY 512
#define IMAGE_CACHE_JPEG_COMPRESSION 1.0

@interface ImageCache : NSObject

- (id) init;

+ (NSInteger) getCount;

+ (id) getObjectWithKey:(NSString *)key;
+ (BOOL) setObject:(id)object forKey:(NSString *)key;

+ (void) checkCache;

@end
