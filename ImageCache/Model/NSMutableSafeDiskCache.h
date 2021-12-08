//
//  NSMutableSafeDiskCache.h
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DiskCacheEvictionMode){
    DiskCacheEvictionAll = 0,
    DiskCacheEvictionMinutes,
    DiskCacheEvictionHours,
    DiskCacheEvictionDays,
    DiskCacheEvictionWeeks,
    DiskCacheEvictionMonths,
};

@interface NSMutableSafeDiskCache : NSObject

+ (instancetype)cacheWithPath:(NSString *)path;

- (void)setObject:(NSData *)object forKey:(NSString *)key;
- (nullable NSData *)objectForKey:(NSString *)key;
- (void)removeAll;
- (void)removeObjectForKey:(NSString *)key;

- (void)setObject:(NSData *)object forKeyedSubscript:(NSString *)key;
- (nullable NSData *)objectForKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
