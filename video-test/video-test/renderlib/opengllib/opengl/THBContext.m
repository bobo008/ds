//
//  CXXContext.m
//  PXCEditor
//
//  Created by huangguanzhe on 2021/7/10.
//

#import "THBContext.h"

#import "GPUImageContext.h"



static void * kCXXContextMainQueueKey = "kCXXContextMainQueueKey";

#pragma mark -
@interface THBContext () {

}
@end

@implementation THBContext

#pragma mark -
+ (instancetype)sharedInstance {
    static id Instance = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        Instance = [[self alloc] init];
    });
    return Instance;
}

- (instancetype)init {
    if (self = [super init]) {
        dispatch_queue_set_specific(dispatch_get_main_queue(), kCXXContextMainQueueKey, &kCXXContextMainQueueKey, NULL);
    }
    return self;
}

#pragma mark -
- (dispatch_queue_t)renderingQueue {

    return [GPUImageContext sharedContextQueue];
}

- (void)runSyncOnRenderingQueue:(void (^)(void))block {
    runSynchronouslyOnVideoProcessingQueue(block);
}

- (void)runAsyncOnRenderingQueue:(void (^)(void))block {
    runAsynchronouslyOnVideoProcessingQueue(block);
}

#pragma mark -
- (void)runSyncOnMainQueue:(void (^)(void))block {
    if (dispatch_get_specific(kCXXContextMainQueueKey)) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end
