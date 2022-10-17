//  Created on 2022/3/9.

#import "MTL3DRenderNode.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"

#import "SEPYpCbCr2RGBUtil.h"

@interface MTL3DRenderNode ()




@end

@implementation MTL3DRenderNode



//@property (nonatomic) matrix_float4x4 mvpMatrix;
//
//@property (nonatomic) matrix_float4x4 pos;
//
//@property (nonatomic) matrix_float4x2 tex;




- (void)render {
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"render 3d";
    pipelineStateDescriptor.sampleCount = 1;
    pipelineStateDescriptor.vertexFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DFragmentShader"];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.outputTexture.texture.pixelFormat;
    
    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    

    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear; // 如果需要清理colorAttachments，调用这个方法
    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;


    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    

    
    /// 传送顶点
    [renderEncoder setVertexBytes:&_pos length:sizeof(float) * 16 atIndex:PPPVertexInputIndexPosition];
    [renderEncoder setVertexBytes:&_tex length:sizeof(float) * 8 atIndex:PPPVertexInputIndexTexcoord];
    
    [renderEncoder setVertexBytes:&_mvpMatrix length:sizeof(float) * 16 atIndex:3];
    
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
