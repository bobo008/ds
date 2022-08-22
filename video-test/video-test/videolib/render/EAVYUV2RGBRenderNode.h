

#import "EAVYUV2RGBRenderNode.h"

#import "THBContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAVYUV2RGBRenderNode : NSObject
+ (instancetype)renderNode;


@property (nonatomic) THBTexture *outputTexture;


@property (nonatomic) GLuint framebufferHandle;

@property (nonatomic) CVPixelBufferRef movieFrame;
@property (nonatomic, nullable) GLfloat *preferredConversion;


- (void)render;

@end

NS_ASSUME_NONNULL_END
