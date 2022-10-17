//  Created on 2022/3/9.

#import "MTL3DRenderProcessor.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"

#import "SEPYpCbCr2RGBUtil.h"

@interface MTL3DRenderProcessor ()
@property (nonatomic) CGSize size;

@property (nonatomic) id<MTLTexture> depth;

@property (nonatomic) MTLRenderPipelineDescriptor *pipelineStateDescriptor;

@property (nonatomic) MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor;

@property (nonatomic) id<MTLDepthStencilState> depthState;

@property (nonatomic) id<MTLRenderPipelineState> renderToTextureRenderPipeline;

@property (nonatomic) id<MTLCommandBuffer> commandBuffer;

@property (nonatomic) id<MTLRenderCommandEncoder> renderEncoder;
@end

@implementation MTL3DRenderProcessor

- (void)setup {
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    
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
    

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"render 3d";
    pipelineStateDescriptor.sampleCount = 1;
    pipelineStateDescriptor.vertexFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DProcessVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [device.defaultLibrary newFunctionWithName:@"mvp3DProcessFragmentShader"];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    pipelineStateDescriptor.vertexDescriptor = mtlVertexDescriptor;
    
    self.pipelineStateDescriptor = pipelineStateDescriptor;
    
    
    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device.device newRenderPipelineStateWithDescriptor:self.pipelineStateDescriptor error:nil];
    self.renderToTextureRenderPipeline = renderToTextureRenderPipeline;
    
    // 搞一个深度纹理
    MTLTextureDescriptor* texDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:self.size.width height:self.size.height mipmapped:false];
    texDesc.usage       |= MTLTextureUsageRenderTarget;
    texDesc.storageMode = MTLStorageModePrivate;
    id<MTLTexture> depth = [device.device newTextureWithDescriptor:texDesc];
    self.depth = depth;
    
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
    depthDescriptor.depthWriteEnabled = YES;
    self.depthState = [device.device newDepthStencilStateWithDescriptor:depthDescriptor];
}



- (void)start {
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    
    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture     = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction  = MTLLoadActionLoad; // 无需clear
//    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor  = MTLClearColorMake(0, 0, 0, 0);
    renderToTextureRenderPassDescriptor.depthAttachment.texture         = self.depth;
    renderToTextureRenderPassDescriptor.depthAttachment.clearDepth      = 1.f;
    renderToTextureRenderPassDescriptor.depthAttachment.loadAction      = MTLLoadActionClear;
    renderToTextureRenderPassDescriptor.depthAttachment.storeAction     = MTLStoreActionStore;
    self.renderToTextureRenderPassDescriptor = renderToTextureRenderPassDescriptor;
    
    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    
    self.commandBuffer = commandBuffer;
    
    self.renderEncoder = [self.commandBuffer renderCommandEncoderWithDescriptor:self.renderToTextureRenderPassDescriptor];
    
    [self.renderEncoder setRenderPipelineState:self.renderToTextureRenderPipeline];
    [self.renderEncoder setDepthStencilState:self.depthState];

}


- (void)render {
    /// 传送顶点
    [self.renderEncoder setVertexBuffer:self.vaoBuffer offset:0 atIndex:0];
    
    [self.renderEncoder setVertexBytes:&_mvpMatrix length:sizeof(float) * 16 atIndex:2];
    
    /// 传送数据
    [self.renderEncoder setFragmentTexture:self.inputTexture.texture atIndex:PPPTextureInputIndexTexture0];
    
    
    if (self.vboBuffer) { // 这种方式最好不要用，我是懒得再写一个类
        [self.renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:self.count indexType:MTLIndexTypeUInt32 indexBuffer:self.vboBuffer indexBufferOffset:0];
    } else {
        [self.renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.count];
    }
}


- (void)end {
    // End encoding commands for this render pass.
    [self.renderEncoder endEncoding];
    
    [self.commandBuffer commit];
}

+ (instancetype)renderNode {
    return [[self alloc] init];
}

+ (instancetype)renderNode:(CGSize)size {
    MTL3DRenderProcessor *renderer = [[self alloc] init];
    renderer.size = size;
    [renderer setup];
    return renderer;
}
@end
