

#import "CXXFillColorRenderNode.h"

@implementation CXXFillColorRenderNode

- (void)render {
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0,
               0,
               (GLsizei)CVPixelBufferGetWidth(_outputTexture.pixelBuffer),
               (GLsizei)CVPixelBufferGetHeight(_outputTexture.pixelBuffer));
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           _outputTexture.textureName,
                           0);
    glClearColor(0., 0., 0., 0.);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
