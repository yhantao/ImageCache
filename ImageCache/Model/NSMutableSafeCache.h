//
//  NSMutableSafeCache.h
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSMutableSafeCache : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPath:(NSString *)path;

- (void)setObject:(NSData *)object forKey:(NSString *)key;
- (nullable NSData *)objectForKey:(NSString *)key;

- (void)removeAll;
- (void)removeObjectForKey:(NSString *)key;

- (void)setObject:(NSData *)object forKeyedSubscript:(NSString *)key;
- (nullable NSData *)objectForKeyedSubscript:(NSString *)key;


NS_ASSUME_NONNULL_END
@end

