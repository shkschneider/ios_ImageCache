//
// ImageCache.m
// Copyright (C) 2012  Alan SCHNEIDER
//                     <contact@shkschneider.me>
//
// This program comes with ABSOLUTELY NO WARRANTY.
// This is free software, and you are welcome to redistribute it
// under certain conditions.
//

#import "ImageCache.h"

/*
 * NSMutableArray *imageHistory {
 *    NSString *hash
 * }
 *
 * NSMutableDictionary *imageMemoryCache {
 *    NSString *hash
 *    UIImage *image
 * }
 */

@implementation ImageCache

/* static */
static NSMutableArray *imageHistory = nil;
static NSMutableDictionary *imageMemoryCache = nil;

- (id) init {
  if (self = [super init])
    {
      NSLog(@"ImageCache initWithCapacity:%d", IMAGE_CACHE_CAPACITY);
      imageHistory = [[NSMutableArray alloc] initWithCapacity:IMAGE_CACHE_CAPACITY] ;
      imageMemoryCache = [[NSMutableDictionary alloc] initWithCapacity:IMAGE_CACHE_CAPACITY] ;
    }
  return self ;
}

+ (NSInteger) getCount {
  return [imageMemoryCache count];
}

+ (NSInteger) getMaxCount {
  return IMAGE_CACHE_CAPACITY;
}

+ (id) getObjectWithKey:(NSString *)key {
  if (IMAGE_CACHE_CAPACITY <= 0)
    return nil;
  UIImage *image = [imageMemoryCache objectForKey:key];
  if (image != nil)
    NSLog(@"ImageCache get %@ at index %d", key, [imageHistory indexOfObject:key]);
  return image;
}

+ (BOOL) setObject:(id)object forKey:(NSString *)key {
  if (IMAGE_CACHE_CAPACITY <= 0)
    return NO;
  if (object == nil)
    NSLog(@"ImageCache no image to cache for %@", key);
  else if (key == nil)
    NSLog(@"ImageCache no key given to cache the image");
  else
    {
      if ([imageMemoryCache count] == IMAGE_CACHE_CAPACITY)
	{
	  NSLog(@"ImageCache is full");
	  [self popObjectAtIndex:IMAGE_CACHE_CAPACITY - 1] ;
	}
      if ([imageMemoryCache count] < IMAGE_CACHE_CAPACITY)
	{
	  NSLog(@"ImageCache add %@ at index %d", key, [imageHistory count] + 1);
	  [imageHistory addObject:key] ;
	  [imageMemoryCache setObject:object forKey:key];
	  //[self dump] ;
	  return YES;
	}
    }
  return NO;
}

- (void) popObjectAtIndex:(NSInteger)index {
  NSString *hash = [imageHistory objectAtIndex:index] ;
  [imageHistory removeObjectAtIndex:index] ;
  [imageMemoryCache removeObjectForKey:hash] ;
  NSLog(@"ImageCache drop %@ at index %d", hash, index);
}

+ (void) dump {
  NSEnumerator *enumerator = [imageHistory objectEnumerator];
  id object;
  for (int i = 0; object = [enumerator nextObject]; i++) {
    NSString *hash = (NSString *)object;
    UIImage *image = [imageMemoryCache objectForKey:hash] ;
    NSLog(@"ImageCache cache[%d] = %@ 0x%p", i, hash, image);
  }
}

+ (void) flush {
  NSLog(@"ImageCache flush");
  for (int index = 0; index < IMAGE_CACHE_CAPACITY; index++)
    [self popObjectAtIndex:index] ;
}

- (NSUInteger)retainCount {
  return NSUIntegerMax; //denotes an object that cannot be released
}

- (void) dealloc {
  [imageHistory release] ;
  [imageMemoryCache release] ;
  [super dealloc] ;
}

@end
