

#import "EAVYUV2RGBRenderNode.h"



#import <OpenGLES/EAGLIOSurface.h>

GLfloat kColorConversion601Default[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
GLfloat kColorConversion601FullRangeDefault[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

// BT.709, which is the standard for HDTV.
GLfloat kColorConversion709Default[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};


GLfloat *kColorConversion601 = kColorConversion601Default;
GLfloat *kColorConversion601FullRange = kColorConversion601FullRangeDefault;
GLfloat *kColorConversion709 = kColorConversion709Default;



@implementation EAVYUV2RGBRenderNode

- (void)render {
    const CVPixelBufferRef movieFrame = _movieFrame;
    if (!movieFrame) {
        NSLog(@"movieFrame is Nil");
        return;
    }
    
    const GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    
    CVOpenGLESTextureCacheRef glTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
    
    const GLfloat *preferredConversion = _preferredConversion;
    if (!preferredConversion) {
        CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
        if (colorAttachments != NULL) {
            if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
                preferredConversion = kColorConversion601;
            } else {
                preferredConversion = kColorConversion709;
            }
        } else {
            preferredConversion = kColorConversion601;
        }
    }
    
    const int movieWidth = (int) CVPixelBufferGetWidth(movieFrame);
    const int movieHeight = (int) CVPixelBufferGetHeight(movieFrame);
    
    const int planeCount = (int) CVPixelBufferGetPlaneCount(movieFrame);
    if (planeCount == 0) {
        NSLog(@"movieFrame plane count is Zero");
        return;
    }
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    
    CVReturn err;
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, glTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, movieWidth, movieHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
    
    if (err) {
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
        return;
    }
    GLuint luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, glTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, movieWidth/2, movieHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
    if (err) {
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
        return;
    }
    glActiveTexture(GL_TEXTURE5);
    GLuint chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


//
//    EAGLContext *ctx = [[PPPGLContext sharedInstance] context];
//
//    GLuint chrominanceTexture;
//    glGenTextures(1, &chrominanceTexture);
//
//    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
//    int planeW = (int)CVPixelBufferGetWidthOfPlane(movieFrame, 1);
//    int planeH = (int)CVPixelBufferGetHeightOfPlane(movieFrame, 1);
//
//    IOSurfaceRef iosurface = CVPixelBufferGetIOSurface(movieFrame);
//    BOOL suc = [ctx texImageIOSurface:iosurface target:GL_TEXTURE_2D internalFormat:GL_LUMINANCE_ALPHA width:planeW height:planeH format:GL_LUMINANCE_ALPHA type:GL_UNSIGNED_BYTE plane:1];
//    CFRelease(iosurface);
//
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//    glPixelStorei(GL_PACK_ALIGNMENT, 1);
//
//    glActiveTexture(GL_TEXTURE5);
//    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//    glBindTexture(GL_TEXTURE_2D, 0);

    

  
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebufferHandle);
    glViewport(0,
               0,
               (GLsizei)CVPixelBufferGetWidth(self.outputTexture.pixelBuffer),
               (GLsizei)CVPixelBufferGetHeight(self.outputTexture.pixelBuffer));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           self.outputTexture.textureName,
                           0);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLProgram *glProgram = [self glProgram];
    [glContext setContextShaderProgram:glProgram];
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f,  1.0f,
    };
    GLuint yuvConversionPositionAttribute = 0; // [glProgram attributeIndex:EAV_GLSL_ATTRIBUTES_POSITION];
    glEnableVertexAttribArray(yuvConversionPositionAttribute);
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    GLuint yuvConversionTextureCoordinateAttribute = 1; // [glProgram attributeIndex:EAV_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    GLuint yuvConversionLuminanceTextureUniform = [glProgram uniformIndex:@"luminanceTexture"];
    glUniform1i(yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    GLuint yuvConversionChrominanceTextureUniform = [glProgram uniformIndex:@"chrominanceTexture"];
    glUniform1i(yuvConversionChrominanceTextureUniform, 5);
    
    GLuint yuvConversionMatrixUniform = [glProgram uniformIndex:@"colorConversionMatrix"];
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, preferredConversion);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
//    glFlush();
    
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    CFRelease(luminanceTextureRef);
    CFRelease(chrominanceTextureRef);
}

- (GLProgram *)glProgram {
    static GLProgram *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *attributeNames = @[
            @"position",
            @"inputTextureCoordinate",
        ];
        instance = GLLoadGLProgram([self shaderWithNamed:@"yue_vs.fsh"], [self shaderWithNamed:@"yue_fs.fsh"], attributeNames);
    });
    return instance;
}


- (NSString *)shaderWithNamed:(NSString *)fileName {
    NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    BOOL isDirectory;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
    if (!isFileExists || isDirectory) {
        NSLog(@"Shader source not exists");
        return nil;
    }
    
    NSError *readShaderSourceError;
    NSString *shaderSource = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&readShaderSourceError];
    if (!shaderSource || readShaderSourceError) {
        NSLog(@"Read shader source failed: %@", readShaderSourceError);
        return nil;
    }
    
    return shaderSource;
}



+ (instancetype)renderNode {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {

        _framebufferHandle = 0;
    }
    return self;
}


@end

