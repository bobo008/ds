
#import "THBGLESTexture.h"


CXXGLESTextureLOD CXXCalcLOD(float width1, float height1, float width2, float height2) {
    NSCParameterAssert(width2 > 0);
    NSCParameterAssert(height2 > 0);
    const double k = sqrt(MAX(1.0, (width1 * height1) / (width2 * height2)));
    return MIN(CXXGLESTextureLOD_Compress1024AndMore, (UInt32)(ABS(round(log2(k)))));
}

CXXGLESTextureLOD CXXCalcLOD2(float width1, float height1, float maxSize) {
    NSCParameterAssert(maxSize > 0);
    float width2, height2;
    if (width1 > height1) {
        width2 = maxSize;
        height2 = maxSize * height1 / width1;
    } else {
        width2 = maxSize * width1 / height1;
        height2 = maxSize;
    }
    return CXXCalcLOD(width1, height1, width2, height2);
}


@implementation THBGLESTexture

+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture {
    return [self createTextureWithPixel:pixel texture:texture orientation:UIImageOrientationUp lod:CXXGLESTextureLOD_Original];
}

+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture orientation:(UIImageOrientation)orientation {
    return [self createTextureWithPixel:pixel texture:texture orientation:orientation lod:CXXGLESTextureLOD_Original];
}

+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture lod:(CXXGLESTextureLOD)lod {
    return [self createTextureWithPixel:pixel texture:texture orientation:UIImageOrientationUp lod:lod];
}

+ (instancetype)createTextureWithPixel:(CVPixelBufferRef)pixel texture:(CVOpenGLESTextureRef)texture orientation:(UIImageOrientation)orientation lod:(CXXGLESTextureLOD)lod {
    THBGLESTexture *ins = [[self alloc] init];
    ins->pixel = pixel;
    ins->texture = texture;
    ins->orientation = orientation;
    ins->lod = lod;
    return ins;
}

- (void)retainGLESTexture {
    CVPixelBufferRetain(pixel);
    CFRetain(texture);
}

- (void)releaseGLESTexture {
    CVPixelBufferRelease(pixel);
    CFRelease(texture);
}


- (CVPixelBufferRef)pixel {
    return pixel;
}

- (CVOpenGLESTextureRef)texture {
    return texture;
}

- (UIImageOrientation)orientation {
    return orientation;
}

- (CXXGLESTextureLOD)lod {
    return lod;
}


- (void)setLod:(CXXGLESTextureLOD)lod {
    self->lod = lod;
}

- (BOOL)lossy {
    return lod != CXXGLESTextureLOD_Original;
}

@end



@implementation THBGLESTexture(Convenience)

- (size_t)costBytes {
    return CVPixelBufferGetBytesPerRow(pixel) * CVPixelBufferGetHeight(pixel);
}

- (size_t)widthInPixels {
    return CVPixelBufferGetWidth(pixel);
}

- (size_t)heightInPixels {
    return CVPixelBufferGetHeight(pixel);
}

- (GLenum)textureTarget {
    return CVOpenGLESTextureGetTarget(texture);
}

- (GLuint)textureName {
    return CVOpenGLESTextureGetName(texture);
}
- (CGSize)sizeInPixels {
    return CGSizeMake(CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel));
}
@end
