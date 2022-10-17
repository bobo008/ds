//  Created on 2022/3/9.

#import "MTLOrientationRenderNode.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"

#import "SEPYpCbCr2RGBUtil.h"

@interface MTLOrientationRenderNode ()




@end

@implementation MTLOrientationRenderNode


- (void)render {
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    

    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device renderPipelineStateWithVertexFunction:@"oneInputVertexShader" fragmentFunction:@"orientationFragmentShader" pixelFormat:self.outputTexture.texture.pixelFormat];


    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    
    const vector_float2 *pos = [PPPMTLRenderDevice defaultPosition];
    const vector_float2 *tex = [PPPMTLRenderDevice textureCoordinatesForOrientation:self.orientation];
    
    /// 传送顶点
    [renderEncoder setVertexBytes:pos length:sizeof(float) * 8 atIndex:PPPVertexInputIndexPosition];
    [renderEncoder setVertexBytes:tex length:sizeof(float) * 8 atIndex:PPPVertexInputIndexTexcoord];
    
//    [renderEncoder setFragmentSamplerState:[[PPPMTLRenderDevice instance] defalutSamplerState] atIndex:0];
    
    /// 传送数据
    [renderEncoder setFragmentTexture:self.inputTexture.texture atIndex:PPPTextureInputIndexTexture0];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
}


+ (instancetype)renderNode {
    return [[self alloc] init];
}

@end
