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
 * Files: ~/Library/Caches/[0-9a-f]+.jpeg
 */

@implementation ImageCache

/* static */
static NSMutableArray *imageHistory = nil;

/*
 * Init the imageHistory with all cached images already in cachesPath
 * Drops if too many
 */
- (id) init {
    if (self = [super init])
    {
        NSLog(@"ImageCache initWithCapacity:%d (~/Library/Caches)", IMAGE_CACHE_CAPACITY);
        imageHistory = [[NSMutableArray alloc] initWithCapacity:IMAGE_CACHE_CAPACITY] ;

        // add already present images to history
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpeg'"] ;
        NSArray *cacheContent = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachesPath error:nil] filteredArrayUsingPredicate:filter] ;
        NSEnumerator *enumerator = [cacheContent objectEnumerator] ;
        id object;
        for (int i = 0; object = [enumerator nextObject]; i++) {
            NSString *hash = [[NSString stringWithString:object] stringByDeletingPathExtension] ;
            //NSLog(@"cache[%d] %@", i, hash);
            [imageHistory addObject:hash] ;
        }

        // drop when too many images at init
        if ([imageHistory count] > IMAGE_CACHE_CAPACITY)
        {
            NSLog(@"ImageCache imageHistory:full");
            while ([imageHistory count] > IMAGE_CACHE_CAPACITY)
            {
                // remove oldest file
                int index = [imageHistory count] - 1;
                NSString *imageHash = [imageHistory objectAtIndex:index] ;
                NSString *imagePath = [[NSString stringWithString:cachesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpeg", imageHash]];
                [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                    NSLog(@"ImageCache drop:%@ failed", imageHash);
                else
                {
                    // remove hash from history
                    NSLog(@"ImageCache drop:%@", imageHash);
                    [imageHistory removeObjectAtIndex:index] ;
                }
            }
        }
        NSLog(@"ImageCache size:%d/%d", [imageHistory count], IMAGE_CACHE_CAPACITY);
    }
    return self ;
}

/*
 * Returns the actual number of cached images
 */
+ (NSInteger) getCount {
    return [imageHistory count];
}

/*
 * Returns the maximum number of cached images
 */
+ (NSInteger) getMaxCount {
    return IMAGE_CACHE_CAPACITY;
}

/*
 * Check if the image asked is cached on the filesystem
 * If yes, returns it
 * If no, returns nil so GetImage get called
 */
+ (id) getObjectWithKey:(NSString *)key {
    if (IMAGE_CACHE_CAPACITY <= 0)
        return nil;
    if (
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSString *imagePath = [[NSString stringWithString:cachesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpeg", key]] ;
    UIImage *retImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        retImage = [UIImage imageWithContentsOfFile:imagePath] ;
        if (retImage != nil)
        {
            NSLog(@"ImageCache getObjectWithKey:%@", key);
            // pop first, no swap
            int index = [imageHistory indexOfObject:key] ;
            NSString *save = [[NSString alloc] initWithString:[imageHistory objectAtIndex:index]] ;
            [imageHistory removeObjectAtIndex:index] ;
            [imageHistory insertObject:save atIndex:0] ;
            [save release] ;
        }
    }
    // image is not on filesystem but is in imageHistory
    else if ([imageHistory indexOfObject:key] != NSNotFound)
        [imageHistory removeObject:key] ;
    return retImage;
}

/*
 * If imageHistory is full, removes the oldest image (by usage)
 * Adds an image to the filesystem as cache (position: 0)
 */
+ (BOOL) setObject:(id)object forKey:(NSString *)key {
    if (IMAGE_CACHE_CAPACITY <= 0)
        return NO;
    else if (object == nil)
        NSLog(@"ImageCache no image to cache for %@", key);
    else if (key == nil)
        NSLog(@"ImageCache no key given to cache the image");
    else {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
        if ([imageHistory count] >= IMAGE_CACHE_CAPACITY)
        {
            NSLog(@"ImageCache imageHistory:full");
            while ([imageHistory count] >= IMAGE_CACHE_CAPACITY)
            {
                // remove oldest file
                int index = [imageHistory count] - 1;
                NSString *imageHash = [imageHistory objectAtIndex:index];
                NSString *imagePath = [[NSString stringWithString:cachesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpeg", imageHash]];
                [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                {
                    NSLog(@"ImageCache drop:%@ failed", imageHash);
                    // remove hash from history
                    [imageHistory removeObjectAtIndex:index] ;
                    [self checkCache] ;
                }
                else
                {
                    NSLog(@"ImageCache drop:%@", imageHash);
                    // remove hash from history
                    [imageHistory removeObjectAtIndex:index] ;
                }
            }
        }
        NSString *imagePath = [[NSString stringWithString:cachesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpeg", key]] ;
        [UIImageJPEGRepresentation(object, IMAGE_CACHE_JPEG_COMPRESSION) writeToFile:imagePath atomically:YES];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            NSLog(@"ImageCache add:%@", key);
            [imageHistory insertObject:key atIndex:0] ;
            return YES;
        }
        NSLog(@"ImageCache write:%@ failed", key);
    }
    return NO;
}

/*
 * Checks the imageHistory with the filesystem
 */
+ (void) checkCache {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpeg'"] ;
    NSArray *cacheContent = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachesPath error:nil] filteredArrayUsingPredicate:filter] ;
    NSEnumerator *enumerator = [cacheContent objectEnumerator] ;
    id object;
    for (int i = 0; object = [enumerator nextObject]; i++) {
        NSString *hash = [[NSString stringWithString:object] stringByDeletingPathExtension] ;
        int index = [imageHistory indexOfObject:hash] ;
        if (index == NSNotFound)
        {
            NSLog(@"ImageCache invalid:%@", hash);
            [imageHistory removeObject:hash] ;
        }
    }
}

- (void) dealloc {
    [imageHistory release] ;
}

@end
