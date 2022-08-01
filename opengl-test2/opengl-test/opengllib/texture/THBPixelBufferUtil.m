

#import "THBPixelBufferUtil.h"
#import <VideoToolbox/VideoToolbox.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <Accelerate/Accelerate.h>

void CGImageToPixelBufferReleaseBytesCallback(void * CV_NULLABLE releaseRefCon, const void * CV_NULLABLE baseAddress) {
    CFTypeRef cf = releaseRefCon;
    if ( CFGetTypeID(cf) == CFDataGetTypeID() ) {
        CFDataRef data = cf;
        CFRelease(data);
    }
}

@implementation THBPixelBufferUtil

#pragma mark -
+ (CVPixelBufferRef)pixelBufferForWidth:(const size_t)width height:(const size_t)height {
    return [self pixelBufferForWidth:width height:height format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)pixelBufferForWidth:(const size_t)width height:(const size_t)height format:(const OSType)format {
    CVPixelBufferRef pixelBuffer = NULL;
    CFDictionaryRef empty;
    CFMutableDictionaryRef attrs;
    CVReturn err;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    err = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, attrs, &pixelBuffer);
    CFRelease(attrs);
    CFRelease(empty);
    if (err != kCVReturnSuccess) {
        NSAssert(NO, @"创建PixelBuffer(width:%zu height:%zu)失败: %d", width, height, err);
        return nil;
    }
    return pixelBuffer;
}

#pragma mark -
+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL {
    return [self pixelBufferForLocalURL:localURL width:0 height:0 maxSize:0 format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL format:(OSType)format {
    return [self pixelBufferForLocalURL:localURL width:0 height:0 maxSize:0 format:format];
}

+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL width:(size_t)width height:(size_t)height maxSize:(size_t)maxSize {
    return [self pixelBufferForLocalURL:localURL width:width height:height maxSize:maxSize format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)pixelBufferForLocalURL:(NSURL *)localURL width:(size_t)width height:(size_t)height maxSize:(size_t)maxSize format:(OSType)format {
    static NSDictionary *options;
    if (!options) {
        options = @{
            (__bridge NSString *) kCGImageSourceShouldCache: @(NO),
            (__bridge NSString *) kCGImageSourceShouldCacheImmediately: @(NO),
            (__bridge NSString *) kCGImageSourceShouldAllowFloat: @(NO),
        };
    }
    
    CVPixelBufferRef pixelBuffer = nil;
    CGImageRef cgImage = nil;
    CGImageSourceRef cgImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)localURL, (__bridge CFDictionaryRef)options);
    if (cgImageSource) {
        if (maxSize > 0 && (width > maxSize || height > maxSize)) {
            NSDictionary *options = @{
                /// CGImageSourceCreateThumbnailAtIndex获取的图片尺寸将是原始图片文件的尺寸。比如，设置 kCGImageSourceThumbnailMaxPixelSize 为600，而如果图片文件尺寸为580*212，那么最终获取到的图片尺寸是580 * 212。所以就算width height 不是正确的，只要比maxSize大，做到压缩图片或者 拿到原图 因为一些bug，导致width height 可能不对。。。
                (__bridge NSString *) kCGImageSourceThumbnailMaxPixelSize: @(maxSize),
                (__bridge NSString *) kCGImageSourceCreateThumbnailFromImageAlways: @(YES),
            };
            cgImage = CGImageSourceCreateThumbnailAtIndex(cgImageSource, 0, (__bridge CFDictionaryRef)options);
        } else {
            cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil);
        }
        CFRelease(cgImageSource);
        if (cgImage) {
            pixelBuffer = [self pixelBufferForCGImage:cgImage format:format];
            CGImageRelease(cgImage);
        } else {
            
        }
    } else {
        
    }
    return pixelBuffer;
}

#pragma mark -
+ (CVPixelBufferRef)pixelBufferForImage:(UIImage *)image {
    return [self pixelBufferForCGImage:image.CGImage format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)pixelBufferForCGImage:(CGImageRef)cgImage {
    return [self pixelBufferForCGImage:cgImage format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)pixelBufferForCGImage:(CGImageRef)cgImage format:(OSType)format {
    assert(cgImage);
    CVPixelBufferRef pixelBuffer = NULL;
    const size_t width = CGImageGetWidth(cgImage);
    const size_t height = CGImageGetHeight(cgImage);
    CFDictionaryRef empty;
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, attrs, &pixelBuffer);
    CFRelease(attrs);
    CFRelease(empty);
    NSAssert(err == kCVReturnSuccess, @"创建PixelBuffer不成功 :%d", err);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *rasterData = CVPixelBufferGetBaseAddress(pixelBuffer);
    const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    const size_t bitsPerComponent = 8;
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    if (format == kCVPixelFormatType_32BGRA) {
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        bitmapInfo = kCGImageAlphaPremultipliedFirst|kCGImageByteOrder32Little;
    } else if (format == kCVPixelFormatType_OneComponent8) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone;
    } else {
        assert(NO);
    }
    CGContextRef context = CGBitmapContextCreate(rasterData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

#pragma mark -
+ (UIImage *)imageForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CGImageRef cgImage = [self cgImageForPixelBuffer:pixelBuffer];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

+ (CGImageRef)cgImageForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    assert(kCVPixelFormatType_32BGRA == CVPixelBufferGetPixelFormatType(pixelBuffer));
    const size_t width = CVPixelBufferGetWidth(pixelBuffer);
    const size_t height = CVPixelBufferGetHeight(pixelBuffer);
    const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    const size_t SIZE = height * bytesPerRow * sizeof(Byte);
    void *data = malloc(SIZE);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Little;
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(data, baseAddress, SIZE);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(data);
    return cgImage;
}




+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation {
    CVPixelBufferLockBaseAddress(pixel, 0);
    vImage_Buffer sourceBuffer = {
        .data = CVPixelBufferGetBaseAddress(pixel),
        .height = CVPixelBufferGetHeight(pixel),
        .width = CVPixelBufferGetWidth(pixel),
        .rowBytes = CVPixelBufferGetBytesPerRow(pixel)
    };
    CVPixelBufferUnlockBaseAddress(pixel, 0);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixel);
    if (   pixelFormat == kCVPixelFormatType_OneComponent8
        || pixelFormat == kCVPixelFormatType_32BGRA
        ) {
        // 希望的格式
    } else {
        NSAssert(NO, @"格式不支持，请扩充");
    }
    
    CGSize size = (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft || orientation == UIImageOrientationRightMirrored || orientation == UIImageOrientationLeftMirrored) ? CGSizeMake(CVPixelBufferGetHeight(pixel), CVPixelBufferGetWidth(pixel)) : CGSizeMake(CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel));
    
    CVPixelBufferRef dstPixel = [THBPixelBufferUtil pixelBufferForWidth:size.width height:size.height format:pixelFormat];
    
    
    CVPixelBufferLockBaseAddress(dstPixel, 0);
    vImage_Buffer destinationBuffer = {
        .data = CVPixelBufferGetBaseAddress(dstPixel),
        .height = CVPixelBufferGetHeight(dstPixel),
        .width = CVPixelBufferGetWidth(dstPixel),
        .rowBytes = CVPixelBufferGetBytesPerRow(dstPixel)
    };

    if (pixelFormat == kCVPixelFormatType_OneComponent8) {
        vImage_CGAffineTransform transform = [self transformWithOrientation:orientation x:CVPixelBufferGetWidth(pixel) y:CVPixelBufferGetHeight(pixel)];
        vImage_Error scaleErr = vImageAffineWarpCG_Planar8(&sourceBuffer, &destinationBuffer, 0, &transform, 0, kvImageBackgroundColorFill);
        NSCAssert(scaleErr == kvImageNoError, @"[vImageAffineWarp_Planar8]: %d", (int)scaleErr);
    } else if (pixelFormat == kCVPixelFormatType_32BGRA) {
        vImage_CGAffineTransform transform = [self transformWithOrientation:orientation x:CVPixelBufferGetWidth(pixel) y:CVPixelBufferGetHeight(pixel)];
        Pixel_8888 backgroundColor = {255, 255, 255, 255};
        vImage_Error scaleErr = vImageAffineWarpCG_ARGB8888(&sourceBuffer, &destinationBuffer, 0, &transform, backgroundColor, kvImageBackgroundColorFill);
        NSCAssert(scaleErr == kvImageNoError, @"[vImageAffineWarp_ARGB8888]: %d", (int)scaleErr);
    }
    CVPixelBufferUnlockBaseAddress(dstPixel, 0);
    
    return dstPixel;
}

+ (vImage_CGAffineTransform)transformWithOrientation:(UIImageOrientation)orientation x:(float)x y:(float)y {
    CGAffineTransform transform = CGAffineTransformIdentity;

    if (orientation == UIImageOrientationUp) {

    }
    if (orientation == UIImageOrientationUpMirrored) {
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    if (orientation == UIImageOrientationDown) {
        transform = CGAffineTransformTranslate(transform, x, y);
        transform = CGAffineTransformRotate(transform, M_PI);

    }
    if (orientation == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, x, y);
        transform = CGAffineTransformRotate(transform, M_PI);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    
    if (orientation == UIImageOrientationLeft) {
        transform = CGAffineTransformTranslate(transform, y, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    if (orientation == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, y, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    
    if (orientation == UIImageOrientationRight) {
        transform = CGAffineTransformTranslate(transform, 0, x);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    if (orientation == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, x);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }

    vImage_CGAffineTransform cg_transform = *((vImage_CGAffineTransform *)&transform);
    return cg_transform;
}





@end

@implementation THBPixelBufferUtil (INP)

+ (CVPixelBufferRef)inp_pixelBufferForImage:(UIImage *)image {
    return [self inp_pixelBufferForCGImage:image.CGImage format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage {
    return [self inp_pixelBufferForCGImage:cgImage format:kCVPixelFormatType_32BGRA];
}

+ (CVPixelBufferRef)inp_pixelBufferForCGImage:(CGImageRef)cgImage format:(OSType)format {
    assert(cgImage);
    CVPixelBufferRef pixelBuffer = NULL;
    const size_t width = CGImageGetWidth(cgImage);
    const size_t height = CGImageGetHeight(cgImage);
    const size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(provider);
    if (!data) {
        return nil;
    }
    void *ptr = (void *)CFDataGetBytePtr(data);
    NSDictionary *pixelBufferAttributes = @{
        (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
    };
    CVReturn err = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, format, ptr, bytesPerRow, CGImageToPixelBufferReleaseBytesCallback, (void *)data, (__bridge CFDictionaryRef _Nullable)(pixelBufferAttributes), &pixelBuffer);
    NSAssert(err == kCVReturnSuccess, @"创建PixelBuffer不成功 :%d", err);
    return pixelBuffer;
}

+ (UIImage *)inp_imageForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CGImageRef cgImage = [self inp_cgImageForPixelBuffer:pixelBuffer];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

+ (CGImageRef)inp_cgImageForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    assert(kCVPixelFormatType_32BGRA == CVPixelBufferGetPixelFormatType(pixelBuffer));
    CGImageRef cgImage;
    OSStatus status = VTCreateCGImageFromCVPixelBuffer(pixelBuffer, NULL, &cgImage);
    NSAssert(status == noErr, nil);
    return cgImage;
}

@end

@implementation THBPixelBufferUtil (GLTexture)
+ (CVOpenGLESTextureRef)textureForPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(CVOpenGLESTextureCacheRef)glTextureCache {
    CVOpenGLESTextureRef texture = NULL;
    if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA) {
        CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                    glTextureCache,
                                                                    pixelBuffer,
                                                                    NULL,
                                                                    GL_TEXTURE_2D,
                                                                    GL_RGBA,
                                                                    (GLsizei)CVPixelBufferGetWidth(pixelBuffer),
                                                                    (GLsizei)CVPixelBufferGetHeight(pixelBuffer),
                                                                    GL_BGRA,
                                                                    GL_UNSIGNED_BYTE,
                                                                    0,
                                                                    &texture);
        if (!texture || err) {
            NSAssert(NO, @"无法创建GLESTextureRef", err);
        }
    } else if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_OneComponent8) {
        CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                    glTextureCache,
                                                                    pixelBuffer,
                                                                    NULL,
                                                                    GL_TEXTURE_2D,
                                                                    GL_LUMINANCE,
                                                                    (GLsizei)CVPixelBufferGetWidth(pixelBuffer),
                                                                    (GLsizei)CVPixelBufferGetHeight(pixelBuffer),
                                                                    GL_LUMINANCE,
                                                                    GL_UNSIGNED_BYTE,
                                                                    0,
                                                                    &texture);
        if (!texture || err) {
            NSAssert(NO, @"无法创建GLESTextureRef", err);
        }
    }
    return texture;
}
@end
