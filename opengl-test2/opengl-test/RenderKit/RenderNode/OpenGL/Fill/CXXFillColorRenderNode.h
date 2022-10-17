

#import <UIKit/UIKit.h>
#import "PPPGLTexture.h"
#import "PPPGLContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface CXXFillColorRenderNode : NSObject
@property (nonatomic) PPPGLTexture *outputTexture;
@property (nonatomic) GLuint framebuffer;

- (void)render;

@end

NS_ASSUME_NONNULL_END
