

#import "PPPGLTexturePool.h"

#import "PPPGLTextureUtil.h"

@interface PPPGLTexture (PTVBitmapPool)
@property (nonatomic, weak, nullable) id<PTVBitmapPoolRecycleProtocol> pool;
- (void)purge;
@end


#pragma mark - PTVBitmapPool

__used static NSString *PTVBitmapPoolKey(CGSize size, OSType format) {
    return [NSString stringWithFormat:@"%d-%d-%u", (int)size.width, (int)size.height, format];
}
__used static NSString *PTVBitmapPoolSizeKey(CGSize size) {
    return [NSString stringWithFormat:@"%d-%d", (int)size.width, (int)size.height];
}

@interface PPPGLTexturePool()<PTVBitmapPoolRecycleProtocol>
@property (nonatomic) NSRecursiveLock *threadLock;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<PPPGLTexture *> *> *cache;
@end

@implementation PPPGLTexturePool

- (void)dealloc {
#ifdef DEBUG
    fprintf(stderr,"\n%s\n", __func__);
    
    [self lockThread];
    NSMutableArray *bitmaps = [NSMutableArray array];
    for (NSArray<PPPGLTexture *> *arr in self.cache.allValues) {
        [bitmaps addObjectsFromArray:arr];
    }
    if (bitmaps.count > 0) {
        fprintf(stderr," WARNING:!!! PTVBitmapPool:%p 还有未释放的bitmap:\n", self);
        for (PPPGLTexture *item in bitmaps) {
            fprintf(stderr, " %s\n", [[item debugDescription] UTF8String]);
        }
    }
    [self unlockThread];
#endif
    
    [self flush];
}

- (instancetype)init {
    self = [super init];
    _threadLock = [[NSRecursiveLock alloc] init];
    _cache = [NSMutableDictionary dictionary];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(UIApplicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)UIApplicationDidReceiveMemoryWarning {
    [self _flushExceptSizeArr:nil];
}

#pragma mark - Create
- (PPPGLTexture *)create:(CGSize)size {
    return [self create:size format:kCVPixelFormatType_32BGRA];
}

- (PPPGLTexture *)create:(CGSize)size format:(OSType)format {
    return [self _create:size format:format];
}

- (PPPGLTexture *)_create:(CGSize)size format:(OSType)format {
    [self lockThread];
    
    NSString *key = PTVBitmapPoolKey(size, format);
    
    NSMutableArray *bitmaps = _cache[key];
    if (!bitmaps) {
        bitmaps = [NSMutableArray array];
        _cache[key] = bitmaps;
    }
    
    PPPGLTexture *target = bitmaps.firstObject;
    if (target) {
        [bitmaps removeObject:target];
        [target lock];
        [self unlockThread];
        return target;
    }
    
    PPPGLTexture *bitmap = [PPPGLTextureUtil createBySize:size format:format];

    bitmap.pool = self;
    [self unlockThread];
    return bitmap;
}

#pragma mark - Flush
- (void)flush {
    [self flushExceptSizeArr:nil];
}

- (void)flushExceptSizeArr:(NSArray<NSValue *> *)sizeArr {
    [self _flushExceptSizeArr:sizeArr];
}

- (void)_flushExceptSizeArr:(NSArray<NSValue *> *_Nullable)sizeArr {
    [self lockThread];
    
    NSArray *values;
    if (sizeArr.count <= 0) {
        values = [_cache allValues];
        [_cache removeAllObjects];
    } else {
        NSMutableSet<NSString *> *keepKeySet = [NSMutableSet set];
        for (NSValue *value in sizeArr) {
            CGSize sss = [value CGSizeValue];
            NSCAssert(sss.width > 0 && sss.height > 0, @"size必须>0");
            NSCAssert(!isnan(sss.width) && !isnan(sss.height), @"size必须合法");
            NSCAssert(!isinf(sss.width) && !isinf(sss.height), @"size必须合法");
            [keepKeySet addObject:PTVBitmapPoolSizeKey(sss)];
        }
        NSArray *keepKeys = [keepKeySet allObjects];
        
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *key in [_cache allKeys]) {
            BOOL needKeep = NO;
            for (NSString *keep in keepKeys) {
                if ([key hasPrefix:keep]) {
                    needKeep = YES; break;
                }
            }
            if (!needKeep) {
                [arr addObject:_cache[key]];
                [_cache removeObjectForKey:key];
            }
        }
        values = arr;
    }
    
    for (NSArray *bitmaps in values) {
        for (PPPGLTexture *bitmap in bitmaps) {
            [bitmap purge];
        }
    }
    
    [self unlockThread];
}

#pragma mark - Recycle
- (void)recycle:(PPPGLTexture *)bitmap {
    [self lockThread];
    
    NSString *key = PTVBitmapPoolKey(bitmap.size, bitmap.format);
    NSMutableArray *bitmaps = _cache[key];
    if (!bitmaps) {
        bitmaps = [NSMutableArray array];
        _cache[key] = bitmaps;
    }
    [bitmaps addObject:bitmap];
    
    [self unlockThread];
}

- (void)lockThread {
    [_threadLock lock];
}

- (void)unlockThread {
    [_threadLock unlock];
}



@end
