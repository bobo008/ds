//
//  THBMsaaTest.m
//  opengl-test
//
//  Created by tanghongbo on 2022/8/2.
//

#import "THBMsaaTest.h"

#import "THBContext.h"

@interface THBMsaaTest()

@property (nonatomic) THBTexture *targetTexture;


@property (nonatomic) THBTexture *inputTexture;

@property (nonatomic) GLfloat *positionData;

@property (nonatomic) GLfloat *texCoordData;

@property (nonatomic) simd_float4x4 mvpMatrix;
@end


/// opengl 上实现msaa 相比较于metal还是比较复杂的，因为从cvpixelbuffer转换的texture是不支持MSAA的，只能使用renderbuffer去实现，metal可以通过创建mtltexture实现,相对简单些
@implementation THBMsaaTest


- (void)render2 {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];


    GLuint mframebuffer;
    glGenFramebuffers(1, &mframebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, mframebuffer);
    
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_RGBA8, (GLsizei)CVPixelBufferGetWidth(_targetTexture.pixel), (GLsizei)CVPixelBufferGetHeight(_targetTexture.pixel));
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    
    glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(_targetTexture.pixel), (GLsizei)CVPixelBufferGetHeight(_targetTexture.pixel));

    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLProgram *glProgram = [self glProgram];
    [glContext setContextShaderProgram:glProgram];
    
    GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
    glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, self.positionData);
    glEnableVertexAttribArray(attributePositionIndex);

    GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
    glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, self.texCoordData);
    glEnableVertexAttribArray(attributeTexCoordIndex);
    
    GLint uniformTransform = [glProgram uniformIndex:@"mvpMatrix"];
    glUniformMatrix4fv(uniformTransform, 1, GL_FALSE, (GLfloat *)&(_mvpMatrix));
    
    
    glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
    glActiveTexture(GL_TEXTURE0);

    
    glBindTexture(CVOpenGLESTextureGetTarget(_inputTexture.texture), CVOpenGLESTextureGetName(_inputTexture.texture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    

    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, mframebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           CVOpenGLESTextureGetTarget(_targetTexture.texture),
                           CVOpenGLESTextureGetName(_targetTexture.texture),
                           0);

    glBlitFramebuffer(0, 0, (GLint)CVPixelBufferGetWidth(_targetTexture.pixel), (GLint)CVPixelBufferGetHeight(_targetTexture.pixel), 0, 0, (GLint)CVPixelBufferGetWidth(_targetTexture.pixel), (GLint)CVPixelBufferGetHeight(_targetTexture.pixel), GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 0, (GLenum[]){GL_COLOR_ATTACHMENT0});

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDeleteFramebuffers(1, &framebuffer);
    glDeleteFramebuffers(1, &mframebuffer);
    glDeleteRenderbuffers(1, &renderBuffer);
}

- (GLProgram *)glProgram {
    NSString *key = @"program.shadow.map";
    static NSMutableDictionary<NSString *, GLProgram *> *glProgramMap = nil;
    if (!glProgramMap) {
        glProgramMap = [NSMutableDictionary dictionary];
    }
    GLProgram *glProgram = [glProgramMap objectForKey:key];
    if (!glProgram) {
        NSArray<NSString *> *attributeNames = @[
            @"position",
            @"inputTextureCoordinate"
        ];
        glProgram = GLLoadGLProgram(@"", @"", attributeNames);
        [glProgramMap setObject:glProgram forKey:key];
    }
    return glProgram;
}


@end
