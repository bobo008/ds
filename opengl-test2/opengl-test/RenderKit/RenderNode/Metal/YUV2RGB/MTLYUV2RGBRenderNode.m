

#import "MTLYUV2RGBRenderNode.h"

#import "PPPPixelBufferUtil.h"

#import "MTLShaderTypes.h"

#import "SEPYpCbCr2RGBUtil.h"

@implementation MTLYUV2RGBRenderNode



- (void)obtainYTexture:(id<MTLTexture> *)yTexture UVTexture:(id<MTLTexture> *)uvTexture pixelbuffer:(CVPixelBufferRef)movieFrame twoBytes:(BOOL)twoBytes {
    if (twoBytes) {
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        IOSurfaceRef surface = CVPixelBufferGetIOSurface(movieFrame);

        uint32_t width = (uint32_t)CVPixelBufferGetWidth(movieFrame);
        uint32_t height = (uint32_t)CVPixelBufferGetHeight(movieFrame);

        MTLTextureDescriptor *desc1 = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR16Unorm width:width height:height mipmapped:NO];
        desc1.usage = MTLTextureUsageShaderRead;
        *yTexture = [[PPPMTLRenderDevice instance].device newTextureWithDescriptor:desc1 iosurface:surface plane:0];
        
        
        uint32_t width2 = (uint32_t)CVPixelBufferGetWidthOfPlane(movieFrame, 1);
        uint32_t height2 = (uint32_t)CVPixelBufferGetHeightOfPlane(movieFrame, 1);
        
        MTLTextureDescriptor *desc2 = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG16Unorm width:width2 height:height2 mipmapped:NO];
        desc2.usage = MTLTextureUsageShaderRead;
        *uvTexture = [[PPPMTLRenderDevice instance].device newTextureWithDescriptor:desc2 iosurface:surface plane:1];
        
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    } else {
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        IOSurfaceRef surface = CVPixelBufferGetIOSurface(movieFrame);

        uint32_t width = (uint32_t)CVPixelBufferGetWidth(movieFrame);
        uint32_t height = (uint32_t)CVPixelBufferGetHeight(movieFrame);

        MTLTextureDescriptor *desc1 = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
        desc1.usage = MTLTextureUsageShaderRead;
        *yTexture = [[PPPMTLRenderDevice instance].device newTextureWithDescriptor:desc1 iosurface:surface plane:0];
        
        
        uint32_t width2 = (uint32_t)CVPixelBufferGetWidthOfPlane(movieFrame, 1);
        uint32_t height2 = (uint32_t)CVPixelBufferGetHeightOfPlane(movieFrame, 1);
        
        MTLTextureDescriptor *desc2 = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm width:width2 height:height2 mipmapped:NO];
        desc2.usage = MTLTextureUsageShaderRead;
        *uvTexture = [[PPPMTLRenderDevice instance].device newTextureWithDescriptor:desc2 iosurface:surface plane:1];
        
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    }
}



- (void)render {
    PPPMTLRenderDevice *device = [PPPMTLRenderDevice instance];
    
    const CVPixelBufferRef movieFrame = _movieFrame;
    const CVPixelBufferRef dstPixel = _outputTexture.pixelBuffer;
    
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(movieFrame);
    if (pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange &&
        pixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarFullRange) {
        NSLog(@"YUVPixel's format unsupport");
        return;
    }
    const BOOL twoBytes = pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange || pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange;
    
    
    CVBufferPropagateAttachments(movieFrame, dstPixel);
    
    
    id<MTLTexture> srcTexture1 = nil;
    id<MTLTexture> srcTexture2 = nil;
    [self obtainYTexture:&srcTexture1 UVTexture:&srcTexture2 pixelbuffer:movieFrame twoBytes:twoBytes];

    id<MTLRenderPipelineState> renderToTextureRenderPipeline = nil;
    if (twoBytes) {
        renderToTextureRenderPipeline = [device renderPipelineStateWithVertexFunction:@"oneInputVertexShader" fragmentFunction:@"yuv2rgb_16u_FragmentShader" pixelFormat:self.outputTexture.texture.pixelFormat];
    } else {
        renderToTextureRenderPipeline = [device renderPipelineStateWithVertexFunction:@"oneInputVertexShader" fragmentFunction:@"yuv2rgbFragmentShader" pixelFormat:self.outputTexture.texture.pixelFormat];
    }

    
    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = self.outputTexture.texture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear; // 如果需要清理colorAttachments，调用这个方法
    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;


    
    id<MTLCommandBuffer> commandBuffer = [device.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    
    const vector_float2 *pos = [PPPMTLRenderDevice defaultPosition];
    const vector_float2 *tex = [PPPMTLRenderDevice textureCoordinatesForOrientation:UIImageOrientationUp];
    
    
//    [renderEncoder setVertexBuffer:[device buffer] offset:0 atIndex:0];
    
    /// 传送顶点
    [renderEncoder setVertexBytes:pos length:sizeof(float) * 8 atIndex:PPPVertexInputIndexPosition];
    [renderEncoder setVertexBytes:tex length:sizeof(float) * 8 atIndex:PPPVertexInputIndexTexcoord];
    /// 传送数据
    [renderEncoder setFragmentTexture:srcTexture1 atIndex:PPPTextureInputIndexTexture0];
    [renderEncoder setFragmentTexture:srcTexture2 atIndex:PPPTextureInputIndexTexture1];

    const float *colorConversionMatrix;
    const float *colorConversionBias;
    SEPAutoSelectConversion(movieFrame, &colorConversionMatrix, &colorConversionBias);
    
    [renderEncoder setFragmentBytes:colorConversionMatrix length:sizeof(matrix_float3x3) atIndex:0];
    [renderEncoder setFragmentBytes:colorConversionBias length:sizeof(vector_float3) atIndex:1];
    
    
//    [renderEncoder setFragmentBuffer:<#(nullable id<MTLBuffer>)#> offset:<#(NSUInteger)#> atIndex:<#(NSUInteger)#>]
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
    

}


- (const vector_float2 *)position {
    static const vector_float2 pos[] = {
        {-1.0,  1.0},
        { 1.0,  1.0},
        {-1.0, -1.0},
        { 1.0, -1.0},
    };
    
    return pos;
}



- (const vector_float2 *)textureCoord {
    static const vector_float2 Up[] = {
        {0.0f, 0.0f},
        {1.0f, 0.0f},
        {0.0f, 1.0f},
        {1.0f, 1.0f},
    };
    return Up;
}



+ (instancetype)renderNode {
    return [[self alloc] init];
}


@end

