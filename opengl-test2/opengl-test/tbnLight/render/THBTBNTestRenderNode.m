

#import "THBTBNTestRenderNode.h"




@interface THBTBNTestRenderNode () {
    GLuint _rbo;
    GLuint _framebuffer;
}


@end

@implementation THBTBNTestRenderNode


- (void)prepareRender {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(self.outputTexture.pixel), (GLsizei)CVPixelBufferGetHeight(self.outputTexture.pixel));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           CVOpenGLESTextureGetTarget(self.outputTexture.texture),
                           CVOpenGLESTextureGetName(self.outputTexture.texture),
                           0);


    glGenRenderbuffers(1, &_rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, _rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, (GLsizei)CVPixelBufferGetWidth(self.outputTexture.pixel), (GLsizei)CVPixelBufferGetHeight(self.outputTexture.pixel));
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rbo);

    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
}



- (void)destroyRender {
    glDisable(GL_DEPTH_TEST);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    
    glDeleteRenderbuffers(1, &_rbo);
    glDeleteFramebuffers(1, &_framebuffer);
}



- (void)render {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];

    
    GLProgram *glProgram = [self glProgram];
    [glContext setContextShaderProgram:glProgram];
    
    
    
    glUniform1i([glProgram uniformIndex:@"inputImageTexture"], 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(CVOpenGLESTextureGetTarget(_inputTexture.texture), CVOpenGLESTextureGetName(_inputTexture.texture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    
    
    
    glUniform1i([glProgram uniformIndex:@"inputImageTexture2"], 1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(CVOpenGLESTextureGetTarget(_inputTexture2.texture), CVOpenGLESTextureGetName(_inputTexture2.texture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    
    

    glUniformMatrix4fv([glProgram uniformIndex:@"pMatrix"], 1, GL_FALSE, (GLfloat *)&(_pMatrix));
    glUniformMatrix4fv([glProgram uniformIndex:@"vMatrix"], 1, GL_FALSE, (GLfloat *)&(_vMatrix));
    glUniformMatrix4fv([glProgram uniformIndex:@"mMatrix"], 1, GL_FALSE, (GLfloat *)&(_mMatrix));
    
    glUniform3f([glProgram uniformIndex:@"lightPos"], -0, 0, 1);
    
    glUniform3f([glProgram uniformIndex:@"viewPos"], _cameraPos.x, _cameraPos.y, _cameraPos.z);

    glBindVertexArray(self.vertexArrayBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexElementBuffer);
    glDrawElements(GL_TRIANGLES, self.indexElementCount, GL_UNSIGNED_INT, 0);
    
    
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

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
            @"inputImageTexture",
            @"aNormal"
        ];
        
        glProgram = CXXLoadGLProgram([self shaderWithNamed:@"light_tbn_vs.fsh"], [self shaderWithNamed:@"light_tbn_fs.fsh"], attributeNames);
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
