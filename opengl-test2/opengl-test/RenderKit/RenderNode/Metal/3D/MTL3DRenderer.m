//  Created on 2022/3/9.

#import "MTL3DRenderer.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"

#import "SEPYpCbCr2RGBUtil.h"

@interface MTL3DRenderer ()




@end

@implementation MTL3DRenderer





- (void)render {
    
    
    
    MTLVertexDescriptor *mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    // Positions.
    mtlVertexDescriptor.attributes[PPPVertexInputIndexPosition].format = MTLVertexFormatFloat3;
    mtlVertexDescriptor.attributes[PPPVertexInputIndexPosition].offset = 0;
    mtlVertexDescriptor.attributes[PPPVertexInputIndexPosition].bufferIndex = 0;

    // Texture coordinates.
    mtlVertexDescriptor.attributes[PPPVertexInputIndexTexcoord].format = MTLVertexFormatFloat2;
    mtlVertexDescriptor.attributes[PPPVertexInputIndexTexcoord].offset = 16;
    mtlVertexDescriptor.attributes[PPPVertexInputIndexTexcoord].bufferIndex = 0;
    
    
    mtlVertexDescriptor.layouts[0].stride = 32;
    mtlVertexDescriptor.layouts[0].stepRate = 1;
    mtlVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    
    
    
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"render 3d";
    pipelineStateDescriptor.sampleCount = 1;
    pipelineStateDescriptor.vertexFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DProcessVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DProcessFragmentShader"];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.outputTexture.texture.pixelFormat;
    pipelineStateDescriptor.vertexDescriptor = mtlVertexDescriptor;
    
    
    
    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    

    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear; // 如果需要清理colorAttachments，调用这个方法
    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0, 0, 1.0);
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;


    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    

    
    
    
//    PPPPosTexVertex vert[] = {
//        {{-1, 1.0, 0.0},     {0.5,0}},
//        {{1.0, -1.0, 0.0},  {1.0,1}},
//        {{-1.0, -1.0, 0.0}, {0,1.0}},
//        {{1.0, 1.0, 0.0},   {0,1.0}},
//    };
//
//    id<MTLBuffer> buffer = [device.device newBufferWithBytes:vert length:sizeof(vert) options:MTLResourceStorageModeShared];
//
    
    /// 传送顶点
    [renderEncoder setVertexBuffer:self.vaoBuffer offset:0 atIndex:0];
    
    [renderEncoder setVertexBytes:&_mvpMatrix length:sizeof(float) * 16 atIndex:2];
    
    /// 传送数据
    [renderEncoder setFragmentTexture:self.inputTexture.texture atIndex:PPPTextureInputIndexTexture0];
    
//
//    vector_int4 aaa[] = {
//        vector4(0, 1, 2,3),
//        vector4(0, 1, 3, 3),
//    };
//    id<MTLBuffer> buffer2 = [device.device newBufferWithBytes:&triangles[0] length:length2 options:MTLResourceStorageModeShared];

    
    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                              indexCount:self.count
                               indexType:MTLIndexTypeUInt32
                             indexBuffer:self.vboBuffer
                       indexBufferOffset:0];


    
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
}


+ (instancetype)renderNode {
    return [[self alloc] init];
}

@end
