

#import "PPPMTLTextureUtil.h"

#import "PPPPixelBufferUtil.h"
#import "PPPGLContext.h"

#import <OpenGLES/EAGLIOSurface.h>


@implementation PPPMTLTextureUtil


+ (PPPMTLTexture *)createWithImage:(UIImage *)image {
    CVPixelBufferRef buffer = [PPPPixelBufferUtil pixelBufferForImage:image];
    
    PPPMTLTexture *bitmap;
    id<MTLTexture> textureName = [self createTextureByPixelBuffer:buffer];
    bitmap = [[PPPMTLTexture alloc] initWithPixelBuffer:buffer textureName:textureName info:nil releaseCallback:nil];

    return bitmap;
}


+ (PPPMTLTexture *)createBySize:(CGSize)size {
    return [self createBySize:size format:kCVPixelFormatType_32BGRA];
}

+ (PPPMTLTexture *)createBySize:(CGSize)size format:(const OSType)format {
    CVPixelBufferRef buffer = [PPPPixelBufferUtil pixelBufferForWidth:size.width height:size.height format:format];
    
    PPPMTLTexture *bitmap;
    id<MTLTexture> textureName = [self createTextureByPixelBuffer:buffer];
    bitmap = [[PPPMTLTexture alloc] initWithPixelBuffer:buffer textureName:textureName info:nil releaseCallback:nil];

    return bitmap;
}


+ (PPPMTLTexture *)createWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferRef buffer = pixelBuffer;
    PPPMTLTexture *bitmap;
    id<MTLTexture> textureName = [self createTextureByPixelBuffer:buffer];
    bitmap = [[PPPMTLTexture alloc] initWithPixelBuffer:buffer textureName:textureName info:nil releaseCallback:nil];

    return bitmap;
}


+ (id<MTLTexture>)createTextureByPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) return 0;
    
    OSType formatType = CVPixelBufferGetPixelFormatType(pixelBuffer);
    uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
    uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    MTLTextureDescriptor* desc = nil;
    if (formatType == kCVPixelFormatType_32BGRA) {
        desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:width height:height mipmapped:NO];
    }
    else if (formatType == kCVPixelFormatType_OneComponent8) {
        desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    }
    else if (formatType == kCVPixelFormatType_64RGBAHalf) {
        desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA16Unorm width:width height:height mipmapped:NO];
    }

    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    IOSurfaceRef surface = CVPixelBufferGetIOSurface(pixelBuffer);
    return [device newTextureWithDescriptor:desc iosurface:surface plane:0];
}

@end


