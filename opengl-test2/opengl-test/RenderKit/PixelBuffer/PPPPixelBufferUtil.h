

#import <UIKit/UIKit.h>

#import "PPPGLTexture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPPPixelBufferUtil : NSObject
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



@end


@interface PPPPixelBufferUtil (vImage)

+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation;

+ (CVPixelBufferRef)resizePixelBuffer:(CVPixelBufferRef)sourcePixelBuffer targetSize:(CGSize)targetSize;
+ (CVPixelBufferRef)_scale:(CVPixelBufferRef)pixel size:(CGSize)targetSize;
@end



@interface PPPPixelBufferUtil (INP)
+ (CVPixelBufferRef)inp_pixelBufferForImage:(UIImage *)image;
+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage;
+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage format:(OSType)format;

+ (UIImage *)inp_imageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
+ (CGImageRef)inp_cgImageForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end


NS_ASSUME_NONNULL_END
