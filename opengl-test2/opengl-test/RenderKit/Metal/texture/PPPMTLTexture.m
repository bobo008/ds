
#import "PPPMTLTexture.h"
#import "PPPMTLTexturePoolProtocol.h"

#ifdef DEBUG
__used static void _PPPMTLBitmapAssert(PPPMTLTexture *bitmap, BOOL bol, NSString *format, ...) {
    if (bol) return ;
    fprintf(stderr,"%s\n", [[bitmap debugDescription] UTF8String]);
    
    va_list params;
    va_start(params, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:params];
    va_end(params);
    str = [str stringByAppendingFormat:@"\n*** bitmap debug:\n    %@\n\n", bitmap.debugDescription];
    NSCAssert(NO, str);
}
#define PPPMTLBitmapAssert(x, ...) _PPPMTLBitmapAssert(self, x, __VA_ARGS__)
#else
#define PPPMTLBitmapAssert(x, ...)
#endif


static int const PPPMTLBitmapPurgeRefCount = -1000;
static int const PPPMTLBitmapUnwarpRefCount = -2000;



@interface PPPMTLTexture()
@property (nonatomic, weak, nullable) id<PPPMTLBitmapPoolRecycleProtocol> pool;

@property (nonatomic, copy, nullable) void(^releaseCallback)(PPPMTLTexture *bitmap);
@property (nonatomic) int refCount;
@end

@implementation PPPMTLTexture

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> refCount=%d, pixel:%p", [self class], self, self.refCount, self.pixelBuffer];
}

- (void)dealloc {
#ifdef DEBUG
    PPPMTLBitmapAssert(_refCount <= 0, @"%s err: refCount>0 必然有lock了但是忘记unlock", __func__);
#endif
    
    if (_refCount > 0) [self unlock];

}




- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(id<MTLTexture>)textureName info:(NSDictionary *)info releaseCallback:(void (^)(PPPMTLTexture * _Nonnull))releaseCallback {
    self = [super init];
    PPPMTLBitmapAssert(pixelBuffer, @"%s err: pixelbuffer = nil", __func__);
    PPPMTLBitmapAssert(CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA ||
                    CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_64RGBAHalf,
                    @"%s err: pixelbuffer.formatType 暂时只支持BGRA32和RGBA64Half", __func__);
    PPPMTLBitmapAssert(textureName, @"%s err: textureName==0", __func__);

    _pixelBuffer = pixelBuffer;
    _texture = textureName;
    _info = info;
    _releaseCallback = releaseCallback;
    _refCount = 1;
    _size = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    _format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    return self;
}

- (void)lock {
    PPPMTLBitmapAssert(_refCount >= 0, @"lock err:该bitmap已经disabled 检查lock unlock purge unwrap");
    _refCount += 1;
}

- (void)unlock {
    PPPMTLBitmapAssert(_refCount >= 1, @"unlock err:该bitmap无法unlock 检查你的lock unlock purge unwrap");
    _refCount -= 1;
    if (_refCount == 0) {
        if (_pool) {
            [_pool recycle:self];
        } else {
            [self purge];
        }
    }
}

- (void)purge {
    _refCount = PPPMTLBitmapPurgeRefCount;
    
    if (_releaseCallback) {
        _releaseCallback(self);
    } else {
        if (_pixelBuffer) CVPixelBufferRelease(_pixelBuffer);
    }
    _texture = nil;
    _pool = nil;
}



@end


#pragma mark - === Category ===
@implementation PPPMTLTexture (Unwrap)

- (CVPixelBufferRef)unwrap {

    PPPMTLBitmapAssert(_pixelBuffer, @"unwarp err:pixelBuffer必须存在");
    PPPMTLBitmapAssert(_refCount > 0, @"unwarp err:unwarp被回收或释放的bitmap 检查lock unlock purge");
    PPPMTLBitmapAssert(_refCount == 1, @"unwarp err:解包时refCount必须=1,代表仅当前一处用，无其他在用");
    
    _refCount = PPPMTLBitmapUnwarpRefCount;
    
    _texture = nil;
    _pool = nil;
    
    CVPixelBufferRef buffer = _pixelBuffer;

    return buffer;
}

@end

@implementation PPPMTLTexture (CachePool)

- (BOOL)fromPool {
    BOOL fromPool = _pool != nil;
    return fromPool;
}

@end

@implementation PPPMTLTexture (Info)

- (void)setInfoValue:(id)value forKey:(NSString *)key {
    NSCParameterAssert(value);
    NSCParameterAssert(key.length > 0);
    if (key.length <= 0 || !value) return ;

    
    NSMutableDictionary *ddd = [NSMutableDictionary dictionary];
    if (_info) [ddd addEntriesFromDictionary:_info];
    ddd[key] = value;
    _info = ddd;
}

- (id)infoValueForKey:(NSString *)key {
    NSCParameterAssert(key);

    id value = _info[key];

    return value;
}

@end

