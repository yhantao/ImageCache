//
//  NSMutableSafeCache.m
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import "NSMutableSafeCache.h"
#import "NSMutableSafeDiskCache.h"


@interface NSMutableSafeCache(){
    NSCache *_ramCache;
    NSMutableSafeDiskCache *_diskCache;
    NSString *_path;
}

@end

@implementation NSMutableSafeCache


- (instancetype) initWithPath:(NSString *)path{
    self = [super init];
    if(self){
        _path = [NSMutableSafeCache filePath:path];
        _ramCache = [[NSCache alloc] init];
        [_ramCache setCountLimit:50];
        _diskCache = [NSMutableSafeDiskCache cacheWithPath:_path];
    }
    return self;
}

- (void)setObject:(NSData *)object forKey:(NSString *)key{
    [_ramCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key];
}

- (nullable NSData *)objectForKey:(NSString *)key{
    
    if(![_ramCache objectForKey:key]){
        NSData *data = [_diskCache objectForKey:key];
        if(data){
            [_ramCache setObject:data forKey:key];
        }
    }
    return [_ramCache objectForKey:key];
    
}
- (void)removeAll{
    [_ramCache removeAllObjects];
    [_diskCache removeAll];
}
- (void)removeObjectForKey:(NSString *)key{
    [_ramCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
    
}

- (void)setObject:(NSData *)object forKeyedSubscript:(NSString *)key{
    [self setObject:object forKey:key];
}

- (nullable NSData *)objectForKeyedSubscript:(NSString *)key{
    return [self objectForKey:key];
}


#pragma mark - Helper functions

+ (NSString *)filePath:(NSString *)lastComponent{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    return [rootPath stringByAppendingPathComponent:lastComponent];
    
}
@end
