

#import <UIKit/UIKit.h>
#import "THBTexture.h"
#import "THBContext.h"




NS_ASSUME_NONNULL_BEGIN

@interface THBShadowTestRenderNode : NSObject

@property (nonatomic) THBTexture *inputTexture;
@property (nonatomic) THBTexture *outputTexture;

@property (nonatomic) THBTexture *inputTexture2;

@property (nonatomic) THBTexture *inputTexture3;


@property (nonatomic) simd_float4x4 pMatrix;
@property (nonatomic) simd_float4x4 vMatrix;
@property (nonatomic) simd_float4x4 mMatrix;
@property (nonatomic) simd_float4x4 shadowMVP;


@property (nonatomic) simd_float3 lightPos;
@property (nonatomic) simd_float3 cameraPos;

@property (nonatomic) GLuint vertexArrayBuffer;
@property (nonatomic) GLuint indexElementBuffer;
@property (nonatomic) GLuint indexElementCount;


- (void)render;



- (void)prepareRender;
- (void)destroyRender;

@end

NS_ASSUME_NONNULL_END
