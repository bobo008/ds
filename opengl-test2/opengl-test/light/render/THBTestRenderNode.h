

#import <UIKit/UIKit.h>
#import "THBTexture.h"
//#import "THBContext.h"



#import "THBPixelBufferUtil.h"
#import "THBTexture.h"
#import "THBPixelBufferPoolAdaptor.h"

#import "GLProgram.h"
#import "GPUImageContext.h"

//#import <simd/simd.h>

#import <simd/types.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBTestRenderNode : NSObject

@property (nonatomic) THBTexture *inputTexture;
@property (nonatomic) THBTexture *outputTexture;

@property (nonatomic) THBTexture *inputTexture2;


@property (nonatomic) simd_float4x4 pMatrix;
@property (nonatomic) simd_float4x4 vMatrix;
@property (nonatomic) simd_float4x4 mMatrix;

@property (nonatomic) simd_float3 cameraPos;

@property (nonatomic) GLuint vertexArrayBuffer;
@property (nonatomic) GLuint indexElementBuffer;
@property (nonatomic) GLuint indexElementCount;


- (void)render;
- (void)render2;
- (void)prepareRender;
- (void)destroyRender;

@end

NS_ASSUME_NONNULL_END
