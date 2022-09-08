//
//  SEPYUV2RGBFilter.m
//  preresearch
//
//  Created by lllllll on 2022/1/17.
//

#import "SEPYUV2RGBFilter.h"
#import "SEPYpCbCr2RGBUtil.h"
#import "THBContext.h"


#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

#define BUNDLE_NAME @"ColorConversion.bundle"

static GLProgram * sharedConversionProgram(void) {
    static GLProgram *program = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *vertString = [[SEPShaderCache sharedInstance] shaderWithNamed:@"YUV2RGB.vsh" andBundleName:BUNDLE_NAME];
        NSString *fragString = [[SEPShaderCache sharedInstance] shaderWithNamed:@"YUV2RGB.fsh" andBundleName:BUNDLE_NAME];
        NSArray<NSString *> *attributeNames = @[
            @"position",
            @"inputTextureCoordinate",
        ];
        program = GLLoadGLProgram(vertString, fragString, attributeNames);
    });
    return program;
}

static GLProgram * sharedConversionProgram16U(void) {
    static GLProgram *program = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *vertString = [[SEPShaderCache sharedInstance] shaderWithNamed:@"YUV2RGB_16U.vsh" andBundleName:BUNDLE_NAME];
        NSString *fragString = [[SEPShaderCache sharedInstance] shaderWithNamed:@"YUV2RGB_16U.fsh" andBundleName:BUNDLE_NAME];
        NSArray<NSString *> *attributeNames = @[
            @"position",
            @"inputTextureCoordinate",
        ];
        program = GLLoadGLProgram(vertString, fragString, attributeNames);
    });
    return program;
}

@implementation SEPYUV2RGBFilter

- (void)render {
    const CVPixelBufferRef YUVPixel = _YUVPixels;
    const CVPixelBufferRef RGBPixel = _RGBPixels;
    const CVOpenGLESTextureRef RGBTexture = _RGBTexture;
    
    if (!YUVPixel) {
        NSLog(@"YUVPixel is Nil");
        return;
    }
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(YUVPixel);
    if (pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarFullRange) {
        NSLog(@"YUVPixel's format unsupport");
        return;
    }
    
    CVBufferPropagateAttachments(YUVPixel, RGBPixel);
    
    const GLfloat *colorConversionMatrix;
    const GLfloat *colorConversionBias;
    SEPAutoSelectConversion(YUVPixel, &colorConversionMatrix, &colorConversionBias);
    
    SEPContext *context = [SEPContext sharedInstance];
    [context useAsCurrentContext];
    CVOpenGLESTextureCacheRef glTextureCache = context.coreVideoTextureCache;
    
    CVReturn err;
    
    const BOOL twoBytes = pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange || pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange;
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    if (twoBytes) {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           glTextureCache,
                                                           YUVPixel,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_R16UI,
                                                           (GLsizei)CVPixelBufferGetWidthOfPlane(YUVPixel, 0),
                                                           (GLsizei)CVPixelBufferGetHeightOfPlane(YUVPixel, 0),
                                                           GL_RED_INTEGER,
                                                           GL_UNSIGNED_SHORT,
                                                           0,
                                                           &luminanceTextureRef);
    } else {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           glTextureCache,
                                                           YUVPixel,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_R8,
                                                           (GLsizei)CVPixelBufferGetWidthOfPlane(YUVPixel, 0),
                                                           (GLsizei)CVPixelBufferGetHeightOfPlane(YUVPixel, 0),
                                                           GL_RED,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &luminanceTextureRef);
    }
    if (err) {
        NSLog(@"Unable to create Y texture: %d", err);
        return;
    }
    
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    if (twoBytes) {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           glTextureCache,
                                                           YUVPixel,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RG16UI,
                                                           (GLsizei)CVPixelBufferGetWidthOfPlane(YUVPixel, 1),
                                                           (GLsizei)CVPixelBufferGetHeightOfPlane(YUVPixel, 1),
                                                           GL_RG_INTEGER,
                                                           GL_UNSIGNED_SHORT,
                                                           1,
                                                           &chrominanceTextureRef);
    } else {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           glTextureCache,
                                                           YUVPixel,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RG8,
                                                           (GLsizei)CVPixelBufferGetWidthOfPlane(YUVPixel, 1),
                                                           (GLsizei)CVPixelBufferGetHeightOfPlane(YUVPixel, 1),
                                                           GL_RG,
                                                           GL_UNSIGNED_BYTE,
                                                           1,
                                                           &chrominanceTextureRef);
    }
    if (err) {
        NSLog(@"Unable to create UV texture: %d", err);
        CFRelease(luminanceTextureRef);
        return;
    }
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(RGBPixel), (GLsizei)CVPixelBufferGetHeight(RGBPixel));
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(RGBTexture), 0);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLProgram *program;
    if (twoBytes) {
        program = sharedConversionProgram16U();
    } else {
        program = sharedConversionProgram();
    }
    [context setCurrentShaderProgram:program];
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f,  1.0f,
    };
    GLuint yuvConversionPositionAttribute = 0;
    glEnableVertexAttribArray(yuvConversionPositionAttribute);
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    GLuint yuvConversionTextureCoordinateAttribute = 1;
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(luminanceTextureRef));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    GLuint yuvConversionLuminanceTextureUniform = [program uniformIndex:@"luminanceTexture"];
    glUniform1i(yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(chrominanceTextureRef));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    GLuint yuvConversionChrominanceTextureUniform = [program uniformIndex:@"chrominanceTexture"];
    glUniform1i(yuvConversionChrominanceTextureUniform, 5);
    
    GLuint yuvConversionMatrixUniform = [program uniformIndex:@"colorConversionMatrix"];
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, colorConversionMatrix);
    
    GLuint yuvConversionBiasUniform = [program uniformIndex:@"colorConversionBias"];
    glUniform3fv(yuvConversionBiasUniform, 1, colorConversionBias);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    CFRelease(luminanceTextureRef);
    CFRelease(chrominanceTextureRef);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, &framebuffer);
    framebuffer = 0;
}

@end
