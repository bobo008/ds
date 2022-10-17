//
//  MNTPPixelBufferPoolAdaptor.m
//  MotionNinja
//
// on 2021/1/11.
//

#import "PPPPixelBufferPoolAdaptor.h"
#import "PPPPixelBufferPool.h"

@implementation PPPPixelBufferPoolAdaptor
{
    BOOL _recording;
    NSMutableSet<NSString *> *_usingSizeSet;
    PPPPixelBufferPool *_pixelBufferPool;
}

+ (instancetype)instance {
    static id Instance = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        Instance = [[self alloc] init];
    });
    return Instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _recording = NO;
        _pixelBufferPool = [[PPPPixelBufferPool alloc] init];
    }
    return self;
}

- (void)enter {
    NSAssert(!_recording, @"");
    if (_recording) return;
    _recording = YES;
    [_usingSizeSet removeAllObjects];
}

- (CVPixelBufferRef)fetch:(CGSize)size {
    NSAssert(_recording, @"");
    if (!_recording) return nil;
    [_usingSizeSet addObject:NSStringFromCGSize(size)];
    CVPixelBufferRef pixelBuffer = [_pixelBufferPool fetch:size];
    return pixelBuffer;
}

- (void)leave {
    NSAssert(_recording, @"");
    if (!_recording) return;
    [_pixelBufferPool purge:_usingSizeSet.copy];
    _recording = NO;
    [_usingSizeSet removeAllObjects];
}
@end
