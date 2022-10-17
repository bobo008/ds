

#import "EAVYUV2RGBRenderNode.h"

#import "PPPGLContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAVYUV2RGBRenderNode : NSObject
+ (instancetype)renderNode;


@property (nonatomic) PPPGLTexture *outputTexture;


@property (nonatomic) GLuint framebufferHandle;

@property (nonatomic) CVPixelBufferRef movieFrame;
@property (nonatomic, nullable) GLfloat *preferredConversion;


- (void)render;

@end

NS_ASSUME_NONNULL_END
