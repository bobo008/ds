//  Created on 2022/3/9.

#import "EAVOrientationRenderNode.h"


#import "THBPixelBufferUtil.h"

#import "AAPLShaderTypes.h"

#import "THBContext.h"

#import <Metal/Metal.h>
#import <Accelerate/Accelerate.h>

@interface EAVOrientationRenderNode ()




@end

@implementation EAVOrientationRenderNode




+ (UIImageOrientation)inverseOrientation:(UIImageOrientation)orientation {

    if (orientation == UIImageOrientationUp) {
        return UIImageOrientationDown;
    }
    if (orientation == UIImageOrientationDown) {
        return UIImageOrientationUp;
    }
    
    
    if (orientation == UIImageOrientationLeft) {
        return UIImageOrientationRight;
    }
    if (orientation == UIImageOrientationRight) {
        return UIImageOrientationLeft;
    }
    
    
    if (orientation == UIImageOrientationUpMirrored) {
        return UIImageOrientationDownMirrored;
    }
    if (orientation == UIImageOrientationDownMirrored) {
        return UIImageOrientationUpMirrored;
    }
    
    
    if (orientation == UIImageOrientationLeftMirrored) {
        return UIImageOrientationRightMirrored;
    }
    if (orientation == UIImageOrientationRightMirrored) {
        return UIImageOrientationLeftMirrored;
    }
    
    return UIImageOrientationDown;
}



+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel inverseOrientation:(UIImageOrientation)orientation {
    return [self correct:pixel orientation:[self inverseOrientation:orientation]];
}






+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation {
    CVPixelBufferLockBaseAddress(pixel, 0);
    
    vImage_Buffer sourceBuffer = {
        .data = CVPixelBufferGetBaseAddress(pixel),
        .height = CVPixelBufferGetHeight(pixel),
        .width = CVPixelBufferGetWidth(pixel),
        .rowBytes = CVPixelBufferGetBytesPerRow(pixel)
    };
    CVPixelBufferUnlockBaseAddress(pixel, 0);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixel);
    if (   pixelFormat == kCVPixelFormatType_OneComponent8
        || pixelFormat == kCVPixelFormatType_32BGRA
        ) {
        // 希望的格式
    } else {
        NSAssert(NO, @"格式不支持，请扩充");
    }
    
    CGSize size = (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft || orientation == UIImageOrientationRightMirrored || orientation == UIImageOrientationLeftMirrored) ? CGSizeMake(CVPixelBufferGetHeight(pixel), CVPixelBufferGetWidth(pixel)) : CGSizeMake(CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel));
    
    CVPixelBufferRef dstPixel = [THBPixelBufferUtil pixelBufferForWidth:size.width height:size.height format:pixelFormat];
    
    CVPixelBufferLockBaseAddress(dstPixel, 0);
    vImage_Buffer destinationBuffer = {
        .data = CVPixelBufferGetBaseAddress(dstPixel),
        .height = CVPixelBufferGetHeight(dstPixel),
        .width = CVPixelBufferGetWidth(dstPixel),
        .rowBytes = CVPixelBufferGetBytesPerRow(dstPixel)
    };

    if (pixelFormat == kCVPixelFormatType_OneComponent8) {
        vImage_CGAffineTransform transform = [self transformWithOrientation:orientation x:CVPixelBufferGetWidth(pixel) y:CVPixelBufferGetHeight(pixel)];
        vImage_Error scaleErr = vImageAffineWarpCG_Planar8(&sourceBuffer, &destinationBuffer, 0, &transform, 255, kvImageBackgroundColorFill | kvImageNoAllocate);
        NSCAssert(scaleErr == kvImageNoError, @"[vImageAffineWarp_Planar8]: %d", (int)scaleErr);
    } else if (pixelFormat == kCVPixelFormatType_32BGRA) {
        vImage_CGAffineTransform transform = [self transformWithOrientation:orientation x:CVPixelBufferGetWidth(pixel) y:CVPixelBufferGetHeight(pixel)];
        Pixel_8888 backgroundColor = {255, 255, 255, 255};
        vImage_Error scaleErr = vImageAffineWarpCG_ARGB8888(&sourceBuffer, &destinationBuffer, 0, &transform, backgroundColor, kvImageBackgroundColorFill | kvImageNoAllocate);
        NSCAssert(scaleErr == kvImageNoError, @"[vImageAffineWarp_ARGB8888]: %d", (int)scaleErr);
    }
    CVPixelBufferUnlockBaseAddress(dstPixel, 0);
    
    return dstPixel;
}

+ (vImage_CGAffineTransform)transformWithOrientation:(UIImageOrientation)orientation x:(float)x y:(float)y {
    CGAffineTransform transform = CGAffineTransformIdentity;

    if (orientation == UIImageOrientationUp) {

    }
    if (orientation == UIImageOrientationUpMirrored) {
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    if (orientation == UIImageOrientationDown) {
        transform = CGAffineTransformTranslate(transform, x, y);
        transform = CGAffineTransformRotate(transform, M_PI);

    }
    if (orientation == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, x, y);
        transform = CGAffineTransformRotate(transform, M_PI);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    
    if (orientation == UIImageOrientationLeft) {
        transform = CGAffineTransformTranslate(transform, y, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    if (orientation == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, y, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    
    if (orientation == UIImageOrientationRight) {
        transform = CGAffineTransformTranslate(transform, 0, x);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    if (orientation == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, x);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        transform = CGAffineTransformTranslate(transform, x, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }

    vImage_CGAffineTransform cg_transform = *((vImage_CGAffineTransform *)&transform);
    return cg_transform;
}



//+ (CVPixelBufferRef)correctUseOpengl:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation {
//
//    __block CVPixelBufferRef ret;
//    [[EAVContext sharedContext] runSyncOnRenderingQueue:^{
//        [GPUImageContext useImageProcessingContext];
//        GLuint framebufferHandle;
//        glGenFramebuffers(1, &framebufferHandle);
//
//        EAVGLTexture *texture = [[EAVGLTexture alloc] init];
//        texture.pixelBuffer = pixel;
//        texture.texture = [EAVPixelBufferUtil textureForPixelBuffer:pixel];
//
//        CGSize size = (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) ? CGSizeMake(texture.pixelSize.height, texture.pixelSize.width) : texture.pixelSize;
//
//
//        EAVGLTexture *output = [EAVPixelBufferUtil createTextureWithSize:size];
//
//        MNFOrientationRenderNode *node = [[MNFOrientationRenderNode alloc] init];
//        node.framebufferHandle = framebufferHandle;
//        node.outputTexture = output;
//        node.inputTexture = texture;
//        node.orientation = orientation;
//
////        glPixelStorei(GL_UNPACK_ALIGNMENT,1);
//
//        [node render];
//        glFinish();
//
//        [texture releaseTexture];
//
//        glDeleteFramebuffers(1, &framebufferHandle);
//        framebufferHandle = 0;
//
//        ret = output.pixelBuffer;
//        [output releaseTexture];
//    }];
//    return ret;
//}



+ (CVPixelBufferRef)correctUseMetal:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation {
    id<MTLTexture> srcTexture = [self obtainTextureWithPixel:pixel];
    
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixel);
    CGSize size = (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) ? CGSizeMake(CVPixelBufferGetHeight(pixel), CVPixelBufferGetWidth(pixel)) : CGSizeMake(CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel));
    CVPixelBufferRef dstPixel = [THBPixelBufferUtil pixelBufferForWidth:size.width height:size.height format:pixelFormat];
    id<MTLTexture> dstTexture = [self obtainTextureWithPixel:dstPixel];
    
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();

    MTLRenderPassDescriptor *renderToTextureRenderPassDescriptor = [MTLRenderPassDescriptor new];
    renderToTextureRenderPassDescriptor.colorAttachments[0].texture = dstTexture;
    renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
    renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"Drawable Render Pipeline";
    pipelineStateDescriptor.sampleCount = 1;
    pipelineStateDescriptor.vertexFunction =  [defaultLibrary newFunctionWithName:@"simpleVertexShader"];
    pipelineStateDescriptor.fragmentFunction =  [defaultLibrary newFunctionWithName:@"simpleFragmentShader"];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = dstTexture.pixelFormat;
    
    id<MTLRenderPipelineState> renderToTextureRenderPipeline = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    /// 这以上的建议长期持有 commandQueue MTLRenderPipelineState 等创建开销比较大
    
    
    

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderToTextureRenderPassDescriptor];
    renderEncoder.label = @"Offscreen Render Pass";
    
    [renderEncoder setRenderPipelineState:renderToTextureRenderPipeline];
    
    const vector_float2 *pos = [self pos];
    const vector_float2 *tex = [self textureCoordinatesForOrientation:orientation];
    
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
    
    return dstPixel;
}



+ (id<MTLTexture>)obtainTextureWithPixel:(CVPixelBufferRef)pixel {
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




+ (const vector_float2 *)pos {
    static const vector_float2 pos[] = {
        {-1.0,  1.0},
        { 1.0,  1.0},
        {-1.0, -1.0},
        { 1.0, -1.0},
    };
    
    return pos;
}

+ (const vector_float2 *)textureCoordinatesForOrientation:(UIImageOrientation)orientation {
    static const vector_float2 Up[] = {
        {0.0f, 0.0f},
        {1.0f, 0.0f},
        {0.0f, 1.0f},
        {1.0f, 1.0f},
    };
    
    static const vector_float2 Left[] = {
        {1.0f, 0.0f},
        {1.0f, 1.0f},
        {0.0f, 0.0f},
        {0.0f, 1.0f},
    };
    
    static const vector_float2 Right[] = {
        {0.0f, 1.0f},
        {0.0f, 0.0f},
        {1.0f, 1.0f},
        {1.0f, 0.0f},
    };
    
    static const vector_float2 Down[] = {
        {1.0f, 1.0f},
        {0.0f, 1.0f},
        {1.0f, 0.0f},
        {0.0f, 0.0f},
    };
    
    
    static const vector_float2 UpMirror[] = {
        {1.0f, 0.0f},
        {0.0f, 0.0f},
        {1.0f, 1.0f},
        {0.0f, 1.0f},
    };
    
    static const vector_float2 LeftMirror[] = {
        {1.0f, 1.0f},
        {1.0f, 0.0f},
        {0.0f, 1.0f},
        {0.0f, 0.0f},
    };
    
    static const vector_float2 RightMirror[] = {
        {0.0f, 0.0f},
        {0.0f, 1.0f},
        {1.0f, 0.0f},
        {1.0f, 1.0f},
    };
    
    static const vector_float2 DownMirror[] = {
        {0.0f, 1.0f},
        {1.0f, 1.0f},
        {0.0f, 0.0f},
        {1.0f, 0.0f},
    };
    
    
    switch(orientation) {
        case UIImageOrientationUp: return Up;
        case UIImageOrientationLeft: return Left;
        case UIImageOrientationDown: return Down;
        case UIImageOrientationRight: return Right;
            
        case UIImageOrientationUpMirrored: return UpMirror;
        case UIImageOrientationLeftMirrored: return LeftMirror;
        case UIImageOrientationDownMirrored: return DownMirror;
        case UIImageOrientationRightMirrored: return RightMirror;
        default: return Up;
    }
}


@end
