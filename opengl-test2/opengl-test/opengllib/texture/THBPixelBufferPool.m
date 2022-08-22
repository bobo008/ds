

#import "THBPixelBufferPool.h"

@interface THBPixelBufferPool ()
@property (nonatomic) NSMutableDictionary<NSString *, id> *poolDict;
@end

@implementation THBPixelBufferPool

+ (instancetype)pool {
    return [[self alloc] init];
}

+ (NSString *)keyWithSize:(CGSize)size formatType:(OSType)formatType {
#if TARGET_RT_BIG_ENDIAN
#   define FourCC2Str(fourcc) (const char[]){*((char*)&fourcc), *(((char*)&fourcc)+1), *(((char*)&fourcc)+2), *(((char*)&fourcc)+3),0}
#else
#   define FourCC2Str(fourcc) (const char[]){*(((char*)&fourcc)+3), *(((char*)&fourcc)+2), *(((char*)&fourcc)+1), *(((char*)&fourcc)+0),0}
#endif
    return [NSString stringWithFormat:@"%d - %d - %s", (int)size.width, (int)size.height, FourCC2Str(formatType)];
#undef FourCC2Str
}

- (instancetype)init {
    if (self = [super init]) {
        self.poolDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size formatType:(OSType)formatType {
    if (size.width == 0 || size.height == 0) {
        NSAssert(NO, @"创建 PixelBuffer 失败");
    }
    NSString *key = [self.class keyWithSize:size formatType:formatType];
    CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)self.poolDict[key];
    if (!pool) {
        NSDictionary *poolAttributes = @{
            (__bridge NSString *)kCVPixelBufferPoolMinimumBufferCountKey: @(0),
            (__bridge NSString *)kCVPixelBufferPoolMaximumBufferAgeKey: @(1),
        };
        NSDictionary *pixelBufferAttributes = @{
            (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(formatType),
            (__bridge NSString *)kCVPixelBufferWidthKey: @(size.width),
            (__bridge NSString *)kCVPixelBufferHeightKey: @(size.height),
            (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
            (__bridge NSString *)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
            (__bridge NSString *)kCVPixelBufferMetalCompatibilityKey: @(YES),
        };
        CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault,
                                               (__bridge CFDictionaryRef)poolAttributes,
                                               (__bridge CFDictionaryRef)pixelBufferAttributes,
                                               &pool);
        NSAssert(err == kCVReturnSuccess, @"创建 PixelBuffer 失败");
        self.poolDict[key] = (__bridge id)pool;
    }
    CVPixelBufferRef pixelBuffer;
    CVReturn err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer);
    NSAssert(err == kCVReturnSuccess, @"创建 PixelBuffer 失败");
    return pixelBuffer;
}

- (void)flush:(NSSet<NSString *> *)usingKeySet {
    [self.poolDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)obj;
        if (pool && ![usingKeySet containsObject:key]) {
            CVPixelBufferPoolFlush(pool, kCVPixelBufferPoolFlushExcessBuffers);
        }
    }];
}

- (void)flushAll {
    [self.poolDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)obj;
        if (pool) {
            CVPixelBufferPoolFlush(pool, kCVPixelBufferPoolFlushExcessBuffers);
        }
    }];
}

- (CVPixelBufferRef)STDPixelBufferWithSize:(CGSize)size {
    return [self pixelBufferWithSize:size formatType:kCVPixelFormatType_32BGRA];
}

- (void)STDFlush:(NSSet<NSValue *> *)usingSizeSet {
    NSMutableSet<NSString *> *usingKeySet = [NSMutableSet set];
    [usingSizeSet enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, BOOL * _Nonnull stop) {
        [usingKeySet addObject:[self.class keyWithSize:[obj CGSizeValue] formatType:kCVPixelFormatType_32BGRA]];
    }];
    [self flush:[usingKeySet copy]];
}

- (void)dealloc {
    for (NSString *key in self.poolDict.allKeys.copy) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)self.poolDict[key];
        if (!pool) continue;
        NSAssert(CVPixelBufferPoolGetTypeID() == CFGetTypeID(pool), @"");
        CVPixelBufferPoolRelease(pool);
        [self.poolDict removeObjectForKey:key];
    }
}

@end
