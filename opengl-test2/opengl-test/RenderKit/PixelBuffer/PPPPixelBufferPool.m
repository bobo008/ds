//
//  MNTPPixelBufferPool.m
//  MotionNinja
//
// on 2021/1/11.
//

#import "PPPPixelBufferPool.h"

@implementation PPPPixelBufferPool
{
    NSMutableDictionary<NSString *, id> *_poolDict;
}

- (instancetype)init {
    if (self = [super init]) {
        _poolDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (CVPixelBufferRef)fetch:(CGSize)size {
    NSString *key = NSStringFromCGSize(size);
    CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)_poolDict[key];
    if (pool == NULL) {
        NSDictionary *poolAttributes = @{
            (__bridge NSString *)kCVPixelBufferPoolMinimumBufferCountKey: @(0),
            (__bridge NSString *)kCVPixelBufferPoolMaximumBufferAgeKey: @(1),
        };
        NSDictionary *pixelBufferAttributes = @{
            (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
            (__bridge NSString *)kCVPixelBufferWidthKey: @(size.width),
            (__bridge NSString *)kCVPixelBufferHeightKey: @(size.height),
            (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
            (__bridge NSString *)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
        };
        CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault,
                                               (__bridge CFDictionaryRef)poolAttributes,
                                               (__bridge CFDictionaryRef)pixelBufferAttributes,
                                               &pool);
        NSAssert(err == kCVReturnSuccess, @"");
        _poolDict[key] = (__bridge id)pool;
    }
    CVPixelBufferRef pixelBuffer;
    CVReturn err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer);
    NSAssert(err == kCVReturnSuccess, @"");
    return pixelBuffer;
}

- (void)purge:(NSSet<NSString *> *)usingSizeSet {
    [_poolDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)obj;
        if (pool && ![usingSizeSet containsObject:key]) {
            CVPixelBufferPoolFlush(pool, kCVPixelBufferPoolFlushExcessBuffers);
        }
    }];
}

- (void)dealloc {
    for (NSString *key in _poolDict.allKeys.copy) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)_poolDict[key];
        if (!pool) continue;
        NSAssert(CVPixelBufferGetTypeID() == CFGetTypeID(pool), @"");
        CVPixelBufferPoolRelease(pool);
        [_poolDict removeObjectForKey:key];
    }
}
@end
