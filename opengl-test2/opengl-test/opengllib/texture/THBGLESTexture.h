
#import <UIKit/UIKit.h>

typedef NS_ENUM(UInt32, CXXGLESTextureLOD) {
    CXXGLESTextureLOD_Original = 0,
    CXXGLESTextureLOD_Compress2,
    CXXGLESTextureLOD_Compress4,
    CXXGLESTextureLOD_Compress8,
    CXXGLESTextureLOD_Compress16,
    CXXGLESTextureLOD_Compress32,
    CXXGLESTextureLOD_Compress64,
    CXXGLESTextureLOD_Compress128,
    CXXGLESTextureLOD_Compress256,
    CXXGLESTextureLOD_Compress512,
    CXXGLESTextureLOD_Compress1024AndMore,
};



CXXGLESTextureLOD CXXCalcLOD(float width1, float height1, float width2, float height2);
CXXGLESTextureLOD CXXCalcLOD2(float width1, float height1, float maxSize);

NS_ASSUME_NONNULL_BEGIN

@interface THBGLESTexture : NSObject {
    CVPixelBufferRef pixel;
    CVOpenGLESTextureRef texture;
    UIImageOrientation orientation;
    CXXGLESTextureLOD lod;
}
@property (nonatomic, readonly) CVPixelBufferRef pixel;
@property (nonatomic, readonly) CVOpenGLESTextureRef texture;
@property (nonatomic, readonly) UIImageOrientation orientation;
@property (nonatomic, readonly) CXXGLESTextureLOD lod;
@property (nonatomic, readonly) BOOL lossy;
+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture;
+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture orientation:(UIImageOrientation)orientation;
+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture lod:(CXXGLESTextureLOD)lod;
+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture orientation:(UIImageOrientation)orientation lod:(CXXGLESTextureLOD)lod;
- (instancetype)init;
- (void)retainGLESTexture;
- (void)releaseGLESTexture;

- (void)setLod:(CXXGLESTextureLOD)lod;
@end


@interface THBGLESTexture(Convenience)
@property (nonatomic, readonly) size_t costBytes;
@property (nonatomic, readonly) size_t widthInPixels;
@property (nonatomic, readonly) size_t heightInPixels;
@property (nonatomic, readonly) CGSize sizeInPixels;
@property (nonatomic, readonly) GLenum textureTarget;
@property (nonatomic, readonly) GLuint textureName;
@end

NS_ASSUME_NONNULL_END
