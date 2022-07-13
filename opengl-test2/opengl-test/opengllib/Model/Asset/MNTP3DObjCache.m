//  Created on 2021/12/29.

#import "MNTP3DObjCache.h"
#import <UIKit/UIKit.h>

#import "THBGLESTexture.h"

@interface MNTP3DObjCache() <NSCacheDelegate>

@property (nonatomic) NSCache<NSString *, MNTP3DAsset *> *cacher;
@property (nonatomic) NSCache<NSString *, THBGLESTexture *> *matrialCacher;

@end

@implementation MNTP3DObjCache

+ (instancetype)instance {
    static id Instance = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        Instance = [[self alloc] init];
    });
    return Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self.cacher removeAllObjects];
        }];
    }
    return self;
}

+ (void)cacheAsset:(MNTP3DAsset *)asset withObjPath:(NSString *)path {
    MNTP3DObjCache *cacher = [self instance];
    [cacher.cacher setObject:asset forKey:path];
}

+ (MNTP3DAsset *)getAssetForPath:(NSString *)path {
    MNTP3DObjCache *cacher = [self instance];
    return [cacher.cacher objectForKey:path];
}

+ (void)cacheTexture:(THBGLESTexture *)texture forMatrialPath:(NSString *)path {
    CGSize size = texture.sizeInPixels;
    NSInteger cost = MAX(1000, size.width * size.height);
    MNTP3DObjCache *cacher = [self instance];
    [cacher.matrialCacher setObject:texture forKey:path cost:cost];
}
+ (THBGLESTexture *)getTextureForMatrialPath:(NSString *)path {
    MNTP3DObjCache *cacher = [self instance];
    return [cacher.matrialCacher objectForKey:path];
}

+ (void)clearAllCache {
    MNTP3DObjCache *cacher = [self instance];
    @autoreleasepool {
        [cacher.cacher removeAllObjects];
        [cacher.matrialCacher removeAllObjects];
    }
}

#pragma mark - NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if (cache == self.matrialCacher) {
        THBGLESTexture *texture = (THBGLESTexture *)obj;
        if ([texture isKindOfClass:THBGLESTexture.class]) {
            [texture releaseGLESTexture];
        }
    }
}

#pragma mark - getter
- (NSCache<NSString *,MNTP3DAsset *> *)cacher {
    if (!_cacher) {
        _cacher = [[NSCache alloc] init];
        _cacher.countLimit = 10;
    }
    return _cacher;
}

- (NSCache<NSString *,THBGLESTexture *> *)matrialCacher {
    if (!_matrialCacher) {
        _matrialCacher = [[NSCache alloc] init];
        _matrialCacher.totalCostLimit = 1080 * 1080 * 20;
        _matrialCacher.delegate = self;
    }
    return _matrialCacher;
}



@end
