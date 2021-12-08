//
//  ImageCacheManager.h
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCacheManager : NSObject

+ (instancetype)sharedManager;

- (void)loadImage:(NSString *)urlString completion:(void(^)(NSData *imgData))completion;
- (void)cancelImageLoading:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
