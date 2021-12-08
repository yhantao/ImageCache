//
//  ImageCacheManager.m
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import "ImageCacheManager.h"
#import "NSMutableSafeCache.h"

@implementation ImageCacheManager{
    NSMutableSafeCache *_imgCache;
    dispatch_queue_t _queue;
    NSMutableDictionary *_tasks;
}

+ (instancetype)sharedManager{
    static ImageCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ImageCacheManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _imgCache = [[NSMutableSafeCache alloc] initWithPath:@"imgCache"];
        _tasks = [NSMutableDictionary new];
    }
    return self;
}

- (void)loadImage:(NSString *)urlString completion:(void(^)(NSData *imgData))completion{
    if(!_imgCache[urlString]){
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self->_tasks removeObjectForKey:urlString];
            if(data){
                self->_imgCache[urlString] = data;
                completion(data);
            }
        }];
        _tasks[urlString] = task;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [task resume];
        });
    }else{
        completion(_imgCache[urlString]);
    }
    
    
    
}
- (void)cancelImageLoading:(NSString *)urlString{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURLSessionDataTask *task = [self->_tasks objectForKey:urlString];
        [task cancel];
        [self->_tasks removeObjectForKey:urlString];
    });
    
}

@end
