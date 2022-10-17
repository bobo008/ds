//  Created on 2022/3/9.

#import "MTLDilateVerticalRenderNode.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"



@interface MTLDilateVerticalRenderNode ()




@end

@implementation MTLDilateVerticalRenderNode


- (void)render {
    int typeDilateOrErode = self.kernel >= 0 ? 0 : 1;
    int kernel = abs(self.kernel) / 2 * 2 + 1;
    
    
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    

    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device renderPipelineStateWithVertexFunction:@"oneInputVertexShader" fragmentFunction:@"dilateVFragmentShader" pixelFormat:self.outputTexture.texture.pixelFormat];


    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    
    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    
    const vector_float2 *pos = [PPPMTLRenderDevice defaultPosition];
    const vector_float2 *tex = [PPPMTLRenderDevice textureCoordinates];
    
    /// 传送顶点
    [renderEncoder setVertexBytes:pos length:sizeof(float) * 8 atIndex:PPPVertexInputIndexPosition];
    [renderEncoder setVertexBytes:tex length:sizeof(float) * 8 atIndex:PPPVertexInputIndexTexcoord];
    

    /// 传送数据
    [renderEncoder setFragmentTexture:self.inputTexture.texture atIndex:PPPTextureInputIndexTexture0];
    
    
    vector_float2 iResolution = simd_make_float2(self.inputTexture.size.width, self.inputTexture.size.height);
    [renderEncoder setFragmentBytes:&iResolution length:sizeof(vector_float2) atIndex:0];
    [renderEncoder setFragmentBytes:&kernel length:sizeof(float) atIndex:1];
    [renderEncoder setFragmentBytes:&typeDilateOrErode length:sizeof(float) atIndex:2];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
}


- (void)finish {
    [[PPPMTLRenderDevice instance] finish];
}

+ (instancetype)renderNode {
    return [[self alloc] init];
}

@end
