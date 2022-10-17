

#import <UIKit/UIKit.h>

#import "PPPMTLRenderDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTLYUV2RGBRenderNode : NSObject
+ (instancetype)renderNode;

@property (nonatomic) PPPMTLTexture *outputTexture;
@property (nonatomic) CVPixelBufferRef movieFrame;

//@property (nonatomic) BOOL clearColor;

- (void)render;

@end

NS_ASSUME_NONNULL_END
