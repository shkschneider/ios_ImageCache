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

@interface ImageCache : NSObject

+ (NSInteger) getCount;
+ (NSInteger) getMaxCount;

+ (id) getObjectWithKey:(NSString *)key;
+ (BOOL) setObject:(id)object forKey:(NSString *)key;

- (void) popObjectAtIndex:(NSInteger)index;
+ (void) dump;
+ (void) flush;

@end
