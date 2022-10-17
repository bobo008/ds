
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN



@interface PPPGLTexture : NSObject
/// 线程不安全的，需要先PTVBitmap lock 用完unlock
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

/// GPUImage单Context环境下没问题 多Context环境需要调用者自行判断context
@property (nonatomic, readonly) GLuint textureName;

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
                        textureName:(GLuint)textureName
                               info:(NSDictionary *_Nullable)info
                    releaseCallback:(void (^_Nullable)(PPPGLTexture * _Nonnull))releaseCallback;

/// refCount+1
- (void)lock;

/// refCount-1  当refCount=0时 触发releaseCallback
- (void)unlock;

@end


#pragma mark - === Category ===
@interface PPPGLTexture (Unwrap)
/// 解常规pixelbuffer包 不触发releaseCallback 调用者用完自行release buffer
/// 不安全的方法，需要调用者外部保证EAGLContext的正确性
- (CVPixelBufferRef)unwrap;
@end

@interface PPPGLTexture (CachePool)
@property (nonatomic, readonly) BOOL fromPool; // 如果是
@end

@interface PPPGLTexture (Info)
- (void)setInfoValue:(id)value forKey:(NSString *)key;
- (id)infoValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
