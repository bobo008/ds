
#import "PPPGLTexture.h"
#import "PPPGLTexturePoolProtocol.h"

#ifdef DEBUG
__used static void _PTVBitmapAssert(PPPGLTexture *bitmap, BOOL bol, NSString *format, ...) {
    if (bol) return ;
    fprintf(stderr,"%s\n", [[bitmap debugDescription] UTF8String]);
    
    va_list params;
    va_start(params, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:params];
    va_end(params);
    str = [str stringByAppendingFormat:@"\n*** bitmap debug:\n    %@\n\n", bitmap.debugDescription];
    NSCAssert(NO, str);
}
#define PTVBitmapAssert(x, ...) _PTVBitmapAssert(self, x, __VA_ARGS__)
#else
#define PTVBitmapAssert(x, ...)
#endif


static int const PTVBitmapPurgeRefCount = -1000;
static int const PTVBitmapUnwarpRefCount = -2000;



@interface PPPGLTexture()
@property (nonatomic) NSRecursiveLock *threadLock;
@property (nonatomic, weak, nullable) id<PTVBitmapPoolRecycleProtocol> pool;

@property (nonatomic, copy, nullable) void(^releaseCallback)(PPPGLTexture *bitmap);
@property (nonatomic) int refCount;
@end

@implementation PPPGLTexture

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> refCount=%d, pixel:%p, texture:%i", [self class], self, self.refCount, self.pixelBuffer, self.textureName];
}

- (void)dealloc {
    [self lockThread];
#ifdef DEBUG
    PTVBitmapAssert(_refCount <= 0, @"%s err: refCount>0 必然有lock了但是忘记unlock", __func__);
#else
    if (_refCount > 0) [self unlock];
#endif
    [self unlockThread];
}




- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(GLuint)textureName info:(NSDictionary *)info releaseCallback:(void (^)(PPPGLTexture * _Nonnull))releaseCallback {
    self = [super init];
    PTVBitmapAssert(pixelBuffer, @"%s err: pixelbuffer = nil", __func__);
    PTVBitmapAssert(CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA ||
                    CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_64RGBAHalf,
                    @"%s err: pixelbuffer.formatType 暂时只支持BGRA32和RGBA64Half", __func__);
    PTVBitmapAssert(textureName, @"%s err: textureName==0", __func__);
    CVPixelBufferRetain(pixelBuffer);
    
    _threadLock = [[NSRecursiveLock alloc] init];
    _pixelBuffer = pixelBuffer;
    _textureName = textureName;
    _info = info;
    _releaseCallback = releaseCallback;
    _refCount = 1;
    _size = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    _format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    return self;
}

- (void)lock {
    [self lockThread];
    PTVBitmapAssert(_refCount >= 0, @"lock err:该bitmap已经disabled 检查lock unlock purge unwrap");
    _refCount += 1;
    [self unlockThread];
}

- (void)unlock {
    [self lockThread];
    PTVBitmapAssert(_refCount >= 1, @"unlock err:该bitmap无法unlock 检查你的lock unlock purge unwrap");
    _refCount -= 1;
    if (_refCount == 0) {
        if (_pool) {
            [_pool recycle:self];
        } else {
            [self purge];
        }
    }
    [self unlockThread];
}

- (void)purge {
    [self lockThread];
    
    _refCount = PTVBitmapPurgeRefCount;
    
    if (_releaseCallback) {
        _releaseCallback(self);
    } else {
        if (_pixelBuffer) CVPixelBufferRelease(_pixelBuffer);
        if (_textureName != 0) {
            glDeleteTextures(1, &_textureName);
        }
    }
    _textureName = 0;
    _pool = nil;
    
    [self unlockThread];
}

- (void)lockThread {
    [_threadLock lock];
}

- (void)unlockThread {
    [_threadLock unlock];
}

@end


#pragma mark - === Category ===
@implementation PPPGLTexture (Unwrap)

- (CVPixelBufferRef)unwrap {
    [self lockThread];
    PTVBitmapAssert(_pixelBuffer, @"unwarp err:pixelBuffer必须存在");
    PTVBitmapAssert(_refCount > 0, @"unwarp err:unwarp被回收或释放的bitmap 检查lock unlock purge");
    PTVBitmapAssert(_refCount == 1, @"unwarp err:解包时refCount必须=1,代表仅当前一处用，无其他在用");
    
    _refCount = PTVBitmapUnwarpRefCount;
    
    if (_textureName > 0) {
        glDeleteTextures(1, &_textureName);;
    }
    _textureName = 0;
    _pool = nil;
    
    CVPixelBufferRef buffer = _pixelBuffer;
    [self unlockThread];
    return buffer;
}

@end

@implementation PPPGLTexture (CachePool)

- (BOOL)fromPool {
    [self lockThread];
    BOOL fromPool = _pool != nil;
    [self unlockThread];
    return fromPool;
}

@end

@implementation PPPGLTexture (Info)

- (void)setInfoValue:(id)value forKey:(NSString *)key {
    NSCParameterAssert(value);
    NSCParameterAssert(key.length > 0);
    if (key.length <= 0 || !value) return ;
    
    [self lockThread];
    
    NSMutableDictionary *ddd = [NSMutableDictionary dictionary];
    if (_info) [ddd addEntriesFromDictionary:_info];
    ddd[key] = value;
    _info = ddd;
    
    [self unlockThread];
}

- (id)infoValueForKey:(NSString *)key {
    NSCParameterAssert(key);
    [self lockThread];
    id value = _info[key];
    [self unlockThread];
    return value;
}

@end

