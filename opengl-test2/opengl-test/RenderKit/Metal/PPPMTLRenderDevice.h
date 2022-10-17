//
//  CXXContext.h
//  PXCEditor
//
//  Created by huangguanzhe on 2021/7/10.
//

#import <Foundation/Foundation.h>

#import "PPPMTLTexture.h"
#import "PPPMTLTexturePool.h"


#import <simd/simd.h>
#import <Metal/Metal.h>

@class MTL3DRenderProcessor;


@interface PPPMTLSamplerOptions : NSObject
@property (nonatomic) MTLSamplerMinMagFilter minFilter;
@property (nonatomic) MTLSamplerMinMagFilter magFilter;
@property (nonatomic) MTLSamplerMipFilter    mipFilter;
@property (nonatomic) MTLSamplerAddressMode  sAddressMode;
@property (nonatomic) MTLSamplerAddressMode  tAddressMode;
@end





@interface PPPMTLRenderDevice : NSObject

@property (nonatomic) id<MTLDevice> device;

@property (nonatomic) id<MTLCommandQueue> commandQueue;

@property (nonatomic) id<MTLLibrary> defaultLibrary;

@property (nonatomic) id<MTLSamplerState> defalutSamplerState;

+ (instancetype)instance;



// 单输出缓存 如果有多输出的麻烦新增一个接口
- (id<MTLRenderPipelineState>)renderPipelineStateWithVertexFunction:(NSString *)vertexFunction fragmentFunction:(NSString *)fragmentFunction pixelFormat:(MTLPixelFormat)pixelFormat;


- (id<MTLSamplerState>)samplerWithSamplerOptions:(PPPMTLSamplerOptions *)options;




+ (const vector_float2 *)defaultPosition;
+ (const vector_float2 *)textureCoordinates;
+ (const vector_float2 *)textureCoordinatesForOrientation:(UIImageOrientation)orientation;



- (id<MTLBuffer>)buffer;

- (void)finish;

- (void)clear;
- (MTL3DRenderProcessor *)renderProcesser:(CGSize)renderSize;


@end




