

#import <UIKit/UIKit.h>

#import "THBTexture.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBPixelBufferUtil : NSObject
+ (nullable CVPixelBufferRef)pixelBufferForWidth:(const size_t)width height:(const size_t)height;
+ (nullable CVPixelBufferRef)pixelBufferForWidth:(const size_t)width height:(const size_t)height format:(const OSType)format;

+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL;
+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL format:(OSType)format;
+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL width:(size_t)width height:(size_t)height maxSize:(size_t)maxSize;
+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL width:(size_t)width height:(size_t)height maxSize:(size_t)maxSize format:(OSType)format;

+ (CVPixelBufferRef)pixelBufferForImage:(UIImage *)image;
+ (CVPixelBufferRef)pixelBufferForCGImage:(CGImageRef)cgImage;
+ (CVPixelBufferRef)pixelBufferForCGImage:(CGImageRef)cgImage format:(OSType)format;

+ (UIImage *)imageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
+ (CGImageRef)cgImageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;


+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation;

@end

@interface THBPixelBufferUtil (INP)
+ (CVPixelBufferRef)inp_pixelBufferForImage:(UIImage *)image;
+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage;
+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage format:(OSType)format;

+ (UIImage *)inp_imageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
+ (CGImageRef)inp_cgImageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

@interface THBPixelBufferUtil (GLTexture)
+ (CVOpenGLESTextureRef)textureForPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(CVOpenGLESTextureCacheRef)glTextureCache;


+ (THBTexture *)createTextureWithSize:(CGSize)size;

+ (THBTexture *)textureForLocalURL:(NSURL *)localURL;
@end

NS_ASSUME_NONNULL_END
