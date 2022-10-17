
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
NS_ASSUME_NONNULL_BEGIN


// 线程不安全，不同线程最好不要同时使用这个类，如果只读的话没问题， 写的话要加锁并且 调用finish
@interface PPPMTLTexture : NSObject

@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

@property (nonatomic, readonly) id<MTLTexture> texture;

@property (nonatomic, readonly) OSType format;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *info;

- (instancetype)init OBJC_UNAVAILABLE("Unavailable init method");



/** 根据pixelbuffer+textureName初始化 refCount=1
 * @param pixelBuffer 会Retain
 * @param textureName 纹理Name
 * @param releaseCallback nil则释放时默认走CFRelease(pixelbuffer) glDeleteTextures(textureName)
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                        textureName:(id<MTLTexture>)textureName
                               info:(NSDictionary *_Nullable)info
                    releaseCallback:(void (^_Nullable)(PPPMTLTexture * _Nonnull))releaseCallback;

/// refCount+1
- (void)lock;

/// refCount-1  当refCount=0时 触发releaseCallback
- (void)unlock;

@end


#pragma mark - === Category ===
@interface PPPMTLTexture (Unwrap)
/// 解常规pixelbuffer包 不触发releaseCallback 调用者用完自行release buffer
/// 不安全的方法，需要调用者外部保证EAGLContext的正确性
- (CVPixelBufferRef)unwrap;
@end

@interface PPPMTLTexture (CachePool)
@property (nonatomic, readonly) BOOL fromPool; // 如果是
@end

@interface PPPMTLTexture (Info)
- (void)setInfoValue:(id)value forKey:(NSString *)key;
- (id)infoValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
