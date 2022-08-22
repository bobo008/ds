

#import "CXXFillColorRenderNode.h"

@implementation CXXFillColorRenderNode

- (void)render {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0,
               0,
               (GLsizei)CVPixelBufferGetWidth(_outputTexture.pixel),
               (GLsizei)CVPixelBufferGetHeight(_outputTexture.pixel));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           CVOpenGLESTextureGetTarget(_outputTexture.texture),
                           CVOpenGLESTextureGetName(_outputTexture.texture),
                           0);
    glClearColor(0., 0., 0., 0.);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
