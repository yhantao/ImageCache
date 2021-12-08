//
//  UIImage+ImageCache.m
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import "UIImageView+ImageCache.h"
#import <objc/runtime.h>
#import "ImageCacheManager.h"

@interface ImageSetter : NSObject{
    NSString *_imgUrl;
}

@end

@implementation ImageSetter

- (instancetype)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void)setOperationWithURL:(NSString *)urlString
                    manager:(ImageCacheManager *)manager
                   callback:(void(^)(NSData *imgData))block{
    [self setImgUrl:urlString];
    [manager loadImage:urlString completion:block];
}

- (void)cancelOperation:(ImageCacheManager *)manager{
    [manager cancelImageLoading: [self imgUrl]];
}


- (void)setImgUrl:(NSString *)url{
    dispatch_barrier_async(dispatch_get_global_queue(0, 0), ^{
        self->_imgUrl = url;
    });
    
}

- (NSString *)imgUrl{
    __block NSString *url;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        url = self->_imgUrl;
    });
    return url;
}


@end

static int imageSetterKey;

@implementation UIImageView (ImageCache)


- (void)setImage:(NSString *)urlString completion:(nullable void(^)(NSTimeInterval loadingTime))completionHandler{
    ImageSetter *setter = objc_getAssociatedObject(self, &imageSetterKey);
    if(!setter){
        setter = [ImageSetter new];
    }
    NSDate *startTime = [NSDate date];
    [setter setOperationWithURL:urlString manager:[ImageCacheManager sharedManager] callback:^(NSData *imgData) {
        if(!imgData) return;
        if(![NSThread isMainThread]){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSData *compressedData = UIImageJPEGRepresentation([UIImage imageWithData:imgData], 0.4);
                [self setImage:[UIImage imageWithData: compressedData]];
                if(completionHandler){
                    completionHandler(-[startTime timeIntervalSinceNow]);
                }
            }];
        }else{
            NSData *compressedData = UIImageJPEGRepresentation([UIImage imageWithData:imgData], 0.4);
            [self setImage:[UIImage imageWithData: compressedData]];
            if(completionHandler){
                completionHandler(-[startTime timeIntervalSinceNow]);
            }
        }
        
    }];
        
    objc_setAssociatedObject(self, &imageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
}

- (void)cancelImageLoading{
    ImageSetter *setter = objc_getAssociatedObject(self, &imageSetterKey);
    if(!setter){
        return;
    }
    [setter cancelOperation:[ImageCacheManager sharedManager]];
}


@end
