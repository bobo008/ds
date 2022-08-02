//  Created on 2022/3/9.

#import "THBMSAARenderNode.h"


#import "THBPixelBufferUtil.h"

#import "AAPLShaderTypes.h"

#import "THBContext.h"

#import <Metal/Metal.h>
#import <Accelerate/Accelerate.h>

@interface THBMSAARenderNode ()

@property (nonatomic) id<MTLTexture> dstTexture;

@property (nonatomic) id<MTLRenderPipelineState> renderToTextureRenderPipeline;

@property (nonatomic) id<MTLCommandQueue> commandQueue;


@property (nonatomic) MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor;

@end

@implementation THBMSAARenderNode



- (CVPixelBufferRef)render {
  
    id<MTLTexture> srcTexture  = [self obtainTextureWithPixel:self.input];
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self.renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:self.renderToTextureRenderPipeline];
    

    static const vector_float2 pos[] = {
        {-1.0,  1.0},
        { 1.0,  1.0},
        {-1.0, -1.0},
        { 1.0, -1.0},
    };
    static const vector_float2 tex[] = {
        {0.0f, 0.0f},
        {1.0f, 0.0f},
        {0.0f, 1.0f},
        {1.0f, 1.0f},
    };
    
    
    AAPLTextureVertex triVertices[] =
    {   //pos   ,  tex
        { pos[0],  tex[0] },
        { pos[1],  tex[1] },
        { pos[2],  tex[2] },
        { pos[3],  tex[3] },
    };
    
    /// 传送顶点
    [renderEncoder setVertexBytes:&triVertices length:sizeof(triVertices) atIndex:AAPLVertexInputIndexVertices];
    /// 传送数据
    [renderEncoder setFragmentTexture:srcTexture atIndex:AAPLTextureInputIndexColor];

    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:3];
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
    
    [commandBuffer waitUntilCompleted];
    
//    CVPixelBufferRef ret = [self getPixelBufferFromBGRAMTLTexture:self.dstTexture];
    return NULL;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor new];
    texDescriptor.textureType = MTLTextureType2DMultisample;
    texDescriptor.width = 1001;
    texDescriptor.height = 1001;
    texDescriptor.sampleCount = 2;/// 通过拿步长可以看到其步长 * 4 * 2 了（所有的四个点，放在同一行中了） 所以 这个性能影响挺大的，要求 2^2 的计算量，这个东西最后呈现到屏幕上可能也有性能问题，最好重绘到一个sampleCount = 1的纹理上再呈现到屏幕上
    texDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    texDescriptor.storageMode = MTLStorageModeShared;
    texDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    self.dstTexture = [device newTextureWithDescriptor:texDescriptor];
    

    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.dstTexture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    self.renderToTextureRenderPassDescriptor = renderToTextureRenderPassDescriptor;
    
    id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MSAA Render Pipeline";
    pipelineStateDescriptor.sampleCount = self.dstTexture.sampleCount;
    pipelineStateDescriptor.vertexFunction =  [defaultLibrary newFunctionWithName:@"msaaVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [defaultLibrary newFunctionWithName:@"msaaFragmentShader"];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.dstTexture.pixelFormat;
    
    self.renderToTextureRenderPipeline = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    self.commandQueue = [device newCommandQueue];
}





- (id<MTLTexture>)obtainTextureWithPixel:(CVPixelBufferRef)pixel {
    CVMetalTextureRef tmpTexture = NULL;
    CVMetalTextureCacheRef textureCache = NULL;
    CVMetalTextureCacheCreate(NULL, NULL, MTLCreateSystemDefaultDevice(), NULL, &textureCache);
    
    
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixel);
    
    if (pixelFormat == kCVPixelFormatType_OneComponent8) {
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixel, NULL, MTLPixelFormatR8Unorm, CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel), 0, &tmpTexture);
    } else if (pixelFormat == kCVPixelFormatType_32BGRA) {
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixel, NULL, MTLPixelFormatBGRA8Unorm, CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel), 0, &tmpTexture);
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    
    return texture;
}




- (CVPixelBufferRef)getPixelBufferFromBGRAMTLTexture:(id<MTLTexture>)texture {
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    size_t imageByteCount = texture.width * texture.height * 4;
    void *imageBytes = malloc(imageByteCount);
    NSUInteger bytesPerRow = texture.width * 4;
    
    MTLRegion region = MTLRegionMake2D(0, 0, texture.width, texture.height);
    [texture getBytes:imageBytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,texture.width,texture.height,kCVPixelFormatType_32BGRA,imageBytes,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    
    free(imageBytes);
    
    return pxbuffer;
}




@end
