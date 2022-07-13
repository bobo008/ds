

#import <UIKit/UIKit.h>
#import "THBGLESTexture.h"
#import "THBContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface CXXFillColorRenderNode : NSObject
@property (nonatomic) THBGLESTexture *outputTexture;
@property (nonatomic) GLuint framebuffer;

- (void)render;

@end

NS_ASSUME_NONNULL_END
