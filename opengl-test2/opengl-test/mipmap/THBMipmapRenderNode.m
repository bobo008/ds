

#import "THBMipmapRenderNode.h"




NSString *const vs = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const fs = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);



@interface THBMipmapRenderNode () {
    GLuint _framebuffer;
}


@end

@implementation THBMipmapRenderNode





/// mip map
- (void)render {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    
    
    THBGLESTexture *outputTexture = [THBPixelBufferUtil createTextureWithSize:CGSizeMake(1000, 1000)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"comics_22.png" ofType:nil];
    THBGLESTexture *inputTexture = [THBPixelBufferUtil textureForLocalURL:[NSURL fileURLWithPath:path]];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(outputTexture.pixel), (GLsizei)CVPixelBufferGetHeight(outputTexture.pixel));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           CVOpenGLESTextureGetTarget(outputTexture.texture),
                           CVOpenGLESTextureGetName(outputTexture.texture),
                           0);


    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    

    GLProgram *glProgram = [self glProgram];
    [glContext setContextShaderProgram:glProgram];
    
    

    CVPixelBufferLockBaseAddress(inputTexture.pixel, 0);
    void *rasterData = CVPixelBufferGetBaseAddress(inputTexture.pixel);
    size_t width = CVPixelBufferGetBytesPerRow(inputTexture.pixel) / 4;
    CVPixelBufferUnlockBaseAddress(inputTexture.pixel, 0);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)inputTexture.heightInPixels, 0, GL_BGRA, GL_UNSIGNED_BYTE, rasterData);
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); /// 记得设置一下采样模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glActiveTexture(GL_TEXTURE0);
    glUniform1i([glProgram uniformIndex:@"inputImageTexture"], 0);
    
    float scale = 0.2;
    GLfloat kDefaultAttributePositionData_ [] = {
        -1.0 * scale, -1.0 * scale,
         1.0 * scale, -1.0 * scale,
        -1.0 * scale,  1.0 * scale,
         1.0 * scale,  1.0 * scale,
    };
    
    GLuint attributePositionIndex = [glProgram attributeIndex:@"position"];
    glVertexAttribPointer(attributePositionIndex, 2, GL_FLOAT, 0, 0, kDefaultAttributePositionData_);
    glEnableVertexAttribArray(attributePositionIndex);
    
    GLfloat kDefaultAttributeTexCoordData_ [] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1,
    };
    
    GLuint attributeTexCoordIndex = [glProgram attributeIndex:@"inputTextureCoordinate"];
    glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, kDefaultAttributeTexCoordData_);
    glEnableVertexAttribArray(attributeTexCoordIndex);


    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glFinish();
    glDeleteTextures(1, &textureID);
    
    
    
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, &_framebuffer);
    
}




#pragma mark -
- (GLProgram *)glProgram {
    NSString *key = @"program.test";
    static NSMutableDictionary<NSString *, GLProgram *> *glProgramMap = nil;
    if (!glProgramMap) {
        glProgramMap = [NSMutableDictionary dictionary];
    }
    GLProgram *glProgram = [glProgramMap objectForKey:key];
    if (!glProgram) {
        NSArray<NSString *> *attributeNames = @[
            @"position",
            @"inputTextureCoordinate",
        ];
        
        glProgram = CXXLoadGLProgram(vs, fs, attributeNames);
        [glProgramMap setObject:glProgram forKey:key];
    }
    return glProgram;
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



@end
