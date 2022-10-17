
#import "THBVideoCompositor.h"
#import "THBContext.h"

#import <objc/runtime.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

static NSMutableDictionary<NSString *, id<THBVideoRenderProtocol>> *renderDicInstance;

@interface THBVideoCompositor () {
    @private
    volatile BOOL _shouldCancelAllRequests;
    volatile BOOL _didEnterBackground;
}
@end

@implementation THBVideoCompositor

+ (void)setVideoRender:(id<THBVideoRenderProtocol>)render {
    if (!renderDicInstance) {
        renderDicInstance = [NSMutableDictionary dictionary];
    }
    NSString *name = NSStringFromClass(self);
    if (render) {
        renderDicInstance[name] = render;
    } else {
        if (renderDicInstance[name]) {
            [renderDicInstance removeObjectForKey:name];
        }
    }
}

+ (id<THBVideoRenderProtocol>)videoRender {
    NSString *name = NSStringFromClass(self);
    
    return renderDicInstance[name];
}

+ (Class<AVVideoCompositing>)subClassWithUniqStr:(NSString *)str {
    NSAssert(str.length > 0, @"参数错误");
    NSString *name = [NSString stringWithFormat:@"THBVideoCompositor_%@", str];
    Class subClass = NSClassFromString(name);
    if (!subClass) {
       subClass =  objc_allocateClassPair(self, [name cStringUsingEncoding:NSUTF8StringEncoding], 0);
        objc_registerClassPair(subClass);
    }
    return subClass;
}

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        _shouldCancelAllRequests = NO;
        _didEnterBackground = NO;
        
        [self _setupApplicationNotificationListener];
        NSLog(@"%@ malloc", self);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
    [self _disposeApplicationNotificationListener];
}

#pragma mark - Install/Uninstall Application Notification
- (void)_setupApplicationNotificationListener {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(_applicationDidEnterBackgroundHandler:)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(_applicationDidBecomeActiveHandler:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

- (void)_disposeApplicationNotificationListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Application Notification Handler
- (void)_applicationDidEnterBackgroundHandler:(NSNotification *)note {
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        if (!self->_didEnterBackground) {
            self->_didEnterBackground = YES;
            [GPUImageContext useImageProcessingContext];
            glFinish();
        }
    }];
}

- (void)_applicationDidBecomeActiveHandler:(NSNotification *)note {
    [[THBContext sharedInstance] runAsyncOnRenderingQueue:^{
        [GPUImageContext useImageProcessingContext];
        if (self->_didEnterBackground) {
            self->_didEnterBackground = NO;
        }
    }];
}

#pragma mark - AVVideoCompositing
- (NSDictionary<NSString *,id> *)sourcePixelBufferAttributes {
    return @{
        (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
        (__bridge NSString *)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
//        (__bridge NSString *)kCVPixelBufferOpenGLESTextureCacheCompatibilityKey: @(YES),
    };
}

- (NSDictionary<NSString *,id> *)requiredPixelBufferAttributesForRenderContext {
    return @{
        (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
        (__bridge NSString *)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
        (__bridge NSString *)kCVPixelBufferOpenGLESTextureCacheCompatibilityKey: @(YES),
    };
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest {
    [[THBContext sharedInstance] runAsyncOnRenderingQueue:^{
        [GPUImageContext useImageProcessingContext];
        @autoreleasepool {
            if (self->_didEnterBackground) {
                [asyncVideoCompositionRequest finishCancelledRequest];
                return;
            }
            if (self->_shouldCancelAllRequests) {
                [asyncVideoCompositionRequest finishCancelledRequest];
                return;
            }
            NSError *error = nil;
            CVPixelBufferRef resultPixels = [self pixelBufferForRequest:asyncVideoCompositionRequest error:&error];
            if (resultPixels) {
                [asyncVideoCompositionRequest finishWithComposedVideoFrame:resultPixels];
                CVPixelBufferRelease(resultPixels);
            } else {
                [asyncVideoCompositionRequest finishWithError:error];
            }
        }
    }];
}

- (void)cancelAllPendingVideoCompositionRequests {
    self->_shouldCancelAllRequests = YES;
    [[THBContext sharedInstance] runAsyncOnRenderingQueue:^{
        [GPUImageContext useImageProcessingContext];
        self->_shouldCancelAllRequests = NO;
    }];
}

#pragma mark - Util
- (CVPixelBufferRef)pixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request error:(NSError **)errOut {
#define RENDER_PRINT_FLAG 1
    
#if defined(DEBUG) && RENDER_PRINT_FLAG
    size_t width = request.renderContext.size.width;
    size_t height = request.renderContext.size.height;
    CMTime time = request.compositionTime;
    NSString *timeString = [NSString stringWithFormat:@"(%lld, %d -> %f)", time.value, time.timescale, CMTimeGetSeconds(time)];
    NSLog(@"Render frame (%zu, %zu) at Time: %@", width, height, timeString);
    CFTimeInterval __render_begin_time = CACurrentMediaTime();
#endif
    CVPixelBufferRef pixels = [self.class.videoRender renderWithRequest:request];
    
#if defined(DEBUG) && RENDER_PRINT_FLAG
    CFTimeInterval __render_end_time = CACurrentMediaTime();
    NSLog(@"Render cost: %fms", (__render_end_time - __render_begin_time) * 1000);
#endif
    return pixels;
}
@end
