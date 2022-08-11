//  Created on 2022/3/9.

#import "THBMipmapMetalNode.h"


#import "THBPixelBufferUtil.h"

#import "AAPLShaderTypes.h"

#import "THBContext.h"

//#import <Metal/Metal.h>

@import MetalKit;

@interface THBMipmapMetalNode ()

@property (nonatomic) id<MTLTexture> dstTexture;

@property (nonatomic) id<MTLRenderPipelineState> renderToTextureRenderPipeline;

@property (nonatomic) id<MTLCommandQueue> commandQueue;


@property (nonatomic) MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor;

@end

@implementation THBMipmapMetalNode



- (CVPixelBufferRef)render {

    /// 想要使用mipmap就不能用cpu共享的pixelbuffer 只能讲数据创建在gpu buffer下，MSAA也相同，数据格式不一样
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();

    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:device];
    
    NSDictionary *textureLoaderOptions =
    @{
      MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
      MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate),
      MTKTextureLoaderOptionAllocateMipmaps    : @YES,
      MTKTextureLoaderOptionGenerateMipmaps    : @YES,
      MTKTextureLoaderOptionSRGB               : @NO
      };

    NSString *path = [[NSBundle mainBundle] pathForResource:@"comics_22.png" ofType:nil];

    NSError *error;
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    id<MTLTexture> srcTexture = [textureLoader newTextureWithCGImage:image.CGImage options:textureLoaderOptions error:&error];
    /// MTLTexture png 图片透明通道显示有问题，转成image又没有问题，可能只是显示问题，这个问题待研究
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self.renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:self.renderToTextureRenderPipeline];
    
    static const float scale = 0.2;
    static const vector_float2 pos[] = {
        {-1.0 * scale,  1.0 * scale},
        { 1.0 * scale,  1.0 * scale},
        {-1.0 * scale, -1.0 * scale},
        { 1.0 * scale, -1.0 * scale},
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

    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    // End encoding commands for this render pass.
    [renderEncoder endEncoding];

    [commandBuffer commit];
    
    [commandBuffer waitUntilCompleted];
    
    CVPixelBufferRef ret = [self getPixelBufferFromBGRAMTLTexture:self.dstTexture];
    UIImage *image2 = [THBPixelBufferUtil imageForPixelBuffer:ret];
    return ret;
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
    texDescriptor.textureType = MTLTextureType2D;
    texDescriptor.width = 1001;
    texDescriptor.height = 1001;
    texDescriptor.sampleCount = 1;
    texDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
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
    pipelineStateDescriptor.vertexFunction =  [defaultLibrary newFunctionWithName:@"mipmapVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [defaultLibrary newFunctionWithName:@"mipmapFragmentShader"];
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
    
//    free(imageBytes); CVPixelBufferCreateWithBytes 不会拷贝 因此这里不能直接释放
    
    return pxbuffer;
}




@end
