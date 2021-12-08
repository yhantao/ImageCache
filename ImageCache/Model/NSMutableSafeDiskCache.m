//
//  NSMutableSafeDiskCache.m
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import "NSMutableSafeDiskCache.h"


@implementation NSMutableSafeDiskCache{
    NSFileManager *_fileManager;
    NSString *_rootPath;
    dispatch_queue_t _queue;
}

+ (instancetype)cacheWithPath:(NSString *)path{
    NSMutableSafeDiskCache *cache = [[NSMutableSafeDiskCache alloc] initWithPath:path];
    [cache removeObjects:DiskCacheEvictionHours];
    return cache;
}

- (instancetype)initWithPath:(NSString *)path{
    self = [super init];
    if(self){
        _fileManager = [NSFileManager defaultManager];
        _rootPath = path;
        _queue = dispatch_queue_create("com.hantao.NSMutableSafeDiskCache", DISPATCH_QUEUE_CONCURRENT);

    }
    return self;
}

- (void)setObject:(NSData *)object forKey:(NSString *)key{
    dispatch_barrier_async(self->_queue, ^{
        NSString *path = [self->_rootPath stringByAppendingPathComponent:key];
        
        [self->_fileManager createFileAtPath:path contents:object attributes:@{NSFileCreationDate:[NSDate date]}];
    });
}

- (nullable NSData *)objectForKey:(NSString *)key{
    __block NSData *data;
    dispatch_sync(self->_queue, ^{
        NSString *path = [self->_rootPath stringByAppendingPathComponent:key];
        data = [self->_fileManager contentsAtPath:path];
    });
    return data;
}

- (void)removeAll{
    dispatch_barrier_async(self->_queue, ^{
        for(NSString *path in [self->_fileManager contentsOfDirectoryAtPath:self->_rootPath error:nil]){
            [self->_fileManager removeItemAtPath:path error:nil];
        }
    });
}

- (void)removeObjectForKey:(NSString *)key{
    dispatch_barrier_async(self->_queue, ^{
        NSString *path = [self->_rootPath stringByAppendingPathComponent:key];
        [self->_fileManager removeItemAtPath:path error:nil];
    });
}

- (void)removeObjects:(DiskCacheEvictionMode)mode{
    switch(mode){
        case DiskCacheEvictionAll:
            [self removeObjectsLongerThan:0];
            break;
        case DiskCacheEvictionMinutes:
            [self removeObjectsLongerThan:60];
            break;
        case DiskCacheEvictionHours:
            [self removeObjectsLongerThan:3600];
            break;
        case DiskCacheEvictionDays:
            [self removeObjectsLongerThan:3600 * 24];
            break;
        case DiskCacheEvictionWeeks:
            [self removeObjectsLongerThan:3600 * 24 * 7];
            break;
        case DiskCacheEvictionMonths:
            [self removeObjectsLongerThan:3600 * 24 * 30];
            break;
        default:
            [self removeObjectsLongerThan:0];
            break;
    }
}

- (void)removeObjectsLongerThan:(int64_t)seconds{
    dispatch_barrier_async(self->_queue, ^{
        for(NSString *path in [self->_fileManager contentsOfDirectoryAtPath:self->_rootPath error:nil]){
            NSDate *createdDate = [self->_fileManager attributesOfItemAtPath:path error:nil][NSFileCreationDate];
            if(!createdDate) continue;
            NSTimeInterval createdDateInterval = -[createdDate timeIntervalSinceNow];
            if(createdDateInterval >= seconds){
                [self->_fileManager removeItemAtPath:path error:nil];
            }
        }
    });
}


- (void)setObject:(NSData *)object forKeyedSubscript:(NSString *)key{
    [self setObject:object forKey:key];
}

- (nullable NSData *)objectForKeyedSubscript:(NSString *)key{
    return [self objectForKey:key];
}


@end
