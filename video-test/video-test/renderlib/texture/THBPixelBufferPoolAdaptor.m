

#import "THBPixelBufferPoolAdaptor.h"
#import "THBPixelBufferPool.h"

@interface THBPixelBufferPoolAdaptor ()
@property (nonatomic) NSMutableSet<NSString *> *usingKeySet;
@property (nonatomic) THBPixelBufferPool *pixelBufferPool;
@property (nonatomic) BOOL recording;
@end

@implementation THBPixelBufferPoolAdaptor

+ (instancetype)adaptor {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _usingKeySet = [NSMutableSet set];
        _pixelBufferPool = [[THBPixelBufferPool alloc] init];
        _recording = NO;
    }
    return self;
}

- (void)dealloc {
    [_pixelBufferPool flushAll];
}

- (void)enter {
    NSAssert(!_recording, @"");
    if (_recording) return;
    _recording = YES;
    [_usingKeySet removeAllObjects];
}

- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size {
    return [self pixelBufferWithSize:size formatType:kCVPixelFormatType_32BGRA];
}

- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size formatType:(OSType)formatType {
    NSAssert(_recording, @"");
    if (!_recording) return nil;
    NSString *key = [_pixelBufferPool.class keyWithSize:size formatType:formatType];
    [_usingKeySet addObject:key];
    CVPixelBufferRef pixelBuffer = [_pixelBufferPool pixelBufferWithSize:size formatType:formatType];
    return pixelBuffer;
}

- (CVPixelBufferRef)pixelBufferWithWidth:(size_t)width height:(size_t)height {
    return [self pixelBufferWithSize:CGSizeMake(width, height)];
}

- (void)leave {
    NSAssert(_recording, @"");
    if (!_recording) return;
    [_pixelBufferPool flush:[_usingKeySet copy]];
    [_usingKeySet removeAllObjects];
    _recording = NO;
}

- (void)clear {
    [_pixelBufferPool flush:[_usingKeySet copy]];
    [_usingKeySet removeAllObjects];
}

@end
