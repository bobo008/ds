
#import "PPPGLTexturePoolProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface PPPGLTexturePool : NSObject<PPPGLTexturePoolProtocol>


- (instancetype)init;

/// 从池子中抓或创建一个size BGRA32的bitmap出来 已经lock
- (PPPGLTexture *)create:(CGSize)size;

/// 从池子中抓或创建一个size 指定format的bitmap出来 已经lock
- (PPPGLTexture *)create:(CGSize)size format:(OSType)format ;


/// 清理池子
- (void)flush;

/// 清理除指定size 传的arr.count==0会全清理 size必须合法且>0
- (void)flushExceptSizeArr:(NSArray<NSValue *> *_Nullable)sizeArr;

@end

NS_ASSUME_NONNULL_END
