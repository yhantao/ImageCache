//
//  UIImage+ImageCache.h
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (ImageCache)

- (void)setImage:(NSString *)urlString completion:(nullable void(^)(NSTimeInterval loadingTime))completionHandler;

- (void)cancelImageLoading;

@end

NS_ASSUME_NONNULL_END
