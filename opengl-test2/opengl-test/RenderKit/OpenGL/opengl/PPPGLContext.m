//
//  CXXContext.m
//  PXCEditor
//
//  Created by huangguanzhe on 2021/7/10.
//

#import "PPPGLContext.h"

#import "GPUImageContext.h"



static void * kCXXContextMainQueueKey = "kCXXContextMainQueueKey";

#pragma mark -
@interface PPPGLContext () {

}
@end

@implementation PPPGLContext

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

+ (void)useImageProcessingContext {
    [[GPUImageContext sharedImageProcessingContext] useAsCurrentContext];
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


- (EAGLContext *)context {
    return [[GPUImageContext sharedImageProcessingContext] context];
}

GLProgram * GLLoadGLProgram(NSString *vertexString, NSString *fragmentString, NSArray<NSString *> *attributeNames) {
    GLProgram *glProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:vertexString
                                                                                   fragmentShaderString:fragmentString];
    if (!glProgram.initialized) {
        for (NSString *attribute in attributeNames) {
            [glProgram addAttribute:attribute];
        }
        if (![glProgram link]) {
            [glProgram validate];
            NSLog(@"vertLog: %@", glProgram.vertexShaderLog);
            NSLog(@"fragLog: %@", glProgram.fragmentShaderLog);
            NSLog(@"progLog: %@", glProgram.programLog);
            NSCAssert(NO, @"无法链接glProgram");
        }
    }
    return glProgram;
}

@end
