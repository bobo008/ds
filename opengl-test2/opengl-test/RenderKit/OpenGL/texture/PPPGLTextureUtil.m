

#import "PPPGLTextureUtil.h"

#import "PPPPixelBufferUtil.h"
#import "PPPGLContext.h"

#import <OpenGLES/EAGLIOSurface.h>


@implementation PPPGLTextureUtil


+ (PPPGLTexture *)createBySize:(CGSize)size {
    return [self createBySize:size format:kCVPixelFormatType_32BGRA];
}

+ (PPPGLTexture *)createBySize:(CGSize)size format:(const OSType)format {
    CVPixelBufferRef buffer = [PPPPixelBufferUtil pixelBufferForWidth:size.width height:size.height format:format];
    
    PPPGLTexture *bitmap;
    GLuint textureName = [self createTextureNameByPixelBuffer2:buffer];
    bitmap = [[PPPGLTexture alloc] initWithPixelBuffer:buffer textureName:textureName info:nil releaseCallback:nil];
    CVPixelBufferRelease(buffer);
    return bitmap;
}


+ (GLuint)createTextureNameByPixelBuffer2:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) return 0;
    
    OSType formatType = CVPixelBufferGetPixelFormatType(pixelBuffer);
    uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
    uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);

    [PPPGLContext useImageProcessingContext];
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    EAGLContext *ctx = [[PPPGLContext sharedInstance] context];
    

    BOOL suc = NO;
    if (formatType == kCVPixelFormatType_32BGRA) {
        suc = [ctx texImageIOSurface:CVPixelBufferGetIOSurface(pixelBuffer) target:GL_TEXTURE_2D internalFormat:GL_RGBA width:width height:height format:GL_BGRA type:GL_UNSIGNED_BYTE plane:0];
    }
    else if (formatType == kCVPixelFormatType_OneComponent8) {
        suc = [ctx texImageIOSurface:CVPixelBufferGetIOSurface(pixelBuffer) target:GL_TEXTURE_2D internalFormat:GL_R8 width:width height:height format:GL_RED type:GL_UNSIGNED_BYTE plane:0];
    }
    else if (formatType == kCVPixelFormatType_64RGBAHalf) {
        suc = [ctx texImageIOSurface:CVPixelBufferGetIOSurface(pixelBuffer) target:GL_TEXTURE_2D internalFormat:GL_RGBA16F width:width height:height format:GL_RGBA type:GL_HALF_FLOAT plane:0];
    }
    NSCAssert(suc, @"无法创建GLESTexture2D");
    return suc ? textureID : 0;
}

@end


