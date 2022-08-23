

#import "THBMutiRenderNode.h"





@interface THBMutiRenderNode () {
    GLuint _framebuffer;
}


@end

@implementation THBMutiRenderNode





/// mip map
- (void)render {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    
    
    THBTexture *outputTexture = [THBPixelBufferUtil createTextureWithSize:CGSizeMake(1000, 1000)];
    
    THBTexture *outputTexture2 = [THBPixelBufferUtil createTextureWithSize:CGSizeMake(1000, 1000)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"comics_22.png" ofType:nil];
    THBTexture *inputTexture = [THBPixelBufferUtil textureForLocalURL:[NSURL fileURLWithPath:path]];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(outputTexture.pixel), (GLsizei)CVPixelBufferGetHeight(outputTexture.pixel));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           CVOpenGLESTextureGetTarget(outputTexture.texture),
                           CVOpenGLESTextureGetName(outputTexture.texture),
                           0);
    
    
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT1,
                           CVOpenGLESTextureGetTarget(outputTexture2.texture),
                           CVOpenGLESTextureGetName(outputTexture2.texture),
                           0);


    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    const GLenum attachments[2] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1};
    glDrawBuffers(2, attachments);

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
    
    float scale = 0.8;
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
    
    
    const GLenum attachments1[1] = {GL_COLOR_ATTACHMENT0};
    glDrawBuffers(1, attachments1);
    
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
        
        glProgram = GLLoadGLProgram([self shaderWithNamed:@"muti_vs.fsh"], [self shaderWithNamed:@"muti_fs.fsh"], attributeNames);
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
