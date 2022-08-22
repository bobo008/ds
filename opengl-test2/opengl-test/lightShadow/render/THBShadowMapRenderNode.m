

#import "THBShadowMapRenderNode.h"


#import "THBContext.h"

static NSString * const shadowVs = SHADER_STRING
(
 
 attribute highp vec4 position;
 attribute highp vec4 inputTextureCoordinate;

 
 varying highp vec2 textureCoordinate;
 varying highp float depth;
 
 uniform highp mat4 model;
 uniform highp mat4 view;
 uniform highp mat4 projection;

 

 void main()
 {
     gl_Position = projection * view * model * vec4(position.xyz, 1.0);
     depth = (gl_Position.z / gl_Position.w + 1.0)/ 2.0;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

static NSString * const shadowFs = SHADER_STRING
(
 
 precision mediump float;
 
 varying highp float depth;
 varying highp vec2 textureCoordinate;
 
 
 vec4 pack (float depth) {
     // 使用rgba 4字节共32位来存储z值,1个字节精度为1/256
     const vec4 bitShift = vec4(1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0);
     const vec4 bitMask = vec4(1.0/256.0, 1.0/256.0, 1.0/256.0, 0.0);
     // gl_FragCoord:片元的坐标,fract():返回数值的小数部分
     vec4 rgbaDepth = fract(depth * bitShift); //计算每个点的z值
     rgbaDepth -= rgbaDepth.gbaa * bitMask; // Cut off the value which do not fit in 8 bits
     return rgbaDepth;
 }
 

 void main() {
//    gl_FragColor = vec4(depth, depth, depth, 1.0);
    gl_FragColor = pack(gl_FragCoord.z);
 }
 );



@interface THBShadowMapRenderNode () {
    GLuint _rbo;
    GLuint _framebuffer;
}


@end

@implementation THBShadowMapRenderNode


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
    
    glUniformMatrix4fv([glProgram uniformIndex:@"projection"], 1, GL_FALSE, (GLfloat *)&(_pMatrix));
    glUniformMatrix4fv([glProgram uniformIndex:@"view"], 1, GL_FALSE, (GLfloat *)&(_vMatrix));
    glUniformMatrix4fv([glProgram uniformIndex:@"model"], 1, GL_FALSE, (GLfloat *)&(_mMatrix));
    
    simd_float4x4 mTranslate = {
        simd_make_float4(-4, -1, -4, 1),
        simd_make_float4(4, -1, -4, 1),
        simd_make_float4(-4, -1, 4, 1),
        simd_make_float4(4, -1, 4, 1),
    };
    simd_float4x4 ret = simd_mul(simd_mul(simd_mul(_pMatrix, _vMatrix),_mMatrix),mTranslate);
    
    glBindVertexArray(self.vertexArrayBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexElementBuffer);
    glDrawElements(GL_TRIANGLES, self.indexElementCount, GL_UNSIGNED_INT, 0);
    

    
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}







#pragma mark -
- (GLProgram *)glProgram {
    NSString *key = @"program。shadow.map";
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
        
        glProgram = GLLoadGLProgram(shadowVs, shadowFs, attributeNames);
        [glProgramMap setObject:glProgram forKey:key];
    }
    return glProgram;
}








@end
