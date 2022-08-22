

#import <UIKit/UIKit.h>
#import "THBTexture.h"
#import "THBContext.h"




NS_ASSUME_NONNULL_BEGIN

@interface THBShadowMapRenderNode : NSObject

@property (nonatomic) THBTexture *outputTexture;

@property (nonatomic) simd_float4x4 pMatrix;
@property (nonatomic) simd_float4x4 vMatrix;
@property (nonatomic) simd_float4x4 mMatrix;

@property (nonatomic) GLuint vertexArrayBuffer;
@property (nonatomic) GLuint indexElementBuffer;
@property (nonatomic) GLuint indexElementCount;


- (void)render;

- (void)prepareRender;
- (void)destroyRender;

@end

NS_ASSUME_NONNULL_END
