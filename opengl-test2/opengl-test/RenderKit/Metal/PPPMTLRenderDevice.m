//
//  CXXContext.m
//  PXCEditor
//
//  Created by huangguanzhe on 2021/7/10.
//

#import "PPPMTLRenderDevice.h"
#import "MTLShaderTypes.h"
#import "MTL3DRenderProcessor.h"


@implementation PPPMTLSamplerOptions
- (instancetype)init {
    if (self = [super init]) {
        self.minFilter = MTLSamplerMinMagFilterLinear;
        self.magFilter = MTLSamplerMinMagFilterNearest;
        self.mipFilter = MTLSamplerMipFilterNearest;
        self.sAddressMode = MTLSamplerAddressModeRepeat;
        self.tAddressMode = MTLSamplerAddressModeRepeat;
    }
    return self;
}

@end


#pragma mark -
@interface PPPMTLRenderDevice ()


@property (nonatomic) NSMutableDictionary<NSString *, id<MTLRenderPipelineState>> *renderPipelineCache;


@property (nonatomic) NSMutableDictionary<NSString *, id<MTLSamplerState>> *samplerStateCache;


@property (nonatomic) MTL3DRenderProcessor *renderer;
@property (nonatomic) CGSize size;
@end

@implementation PPPMTLRenderDevice

#pragma mark -
+ (instancetype)instance {
    static id Instance = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        Instance = [[self alloc] init];
    });
    return Instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.device = MTLCreateSystemDefaultDevice();
        self.commandQueue = [self.device newCommandQueue];
        
        self.defaultLibrary = [self.device newDefaultLibrary];
        
        self.renderPipelineCache = [NSMutableDictionary dictionary];
        
        self.samplerStateCache = [NSMutableDictionary dictionary];
        
        self.defalutSamplerState = [self samplerWithSamplerOptions:[[PPPMTLSamplerOptions alloc] init]];
    }
    return self;
}


- (id<MTLRenderPipelineState>)renderPipelineStateWithVertexFunction:(NSString *)vertexFunction fragmentFunction:(NSString *)fragmentFunction pixelFormat:(MTLPixelFormat)pixelFormat {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%lu", vertexFunction, fragmentFunction, (unsigned long)pixelFormat];
    
    if (self.renderPipelineCache[key]) {
        return self.renderPipelineCache[key];
    } else {
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = key;
        pipelineStateDescriptor.sampleCount = 1;
        pipelineStateDescriptor.vertexFunction =  [self.defaultLibrary newFunctionWithName:vertexFunction];
        pipelineStateDescriptor.fragmentFunction =  [self.defaultLibrary newFunctionWithName:fragmentFunction];
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat;
        
        id<MTLRenderPipelineState> renderPipeline = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
        
        self.renderPipelineCache[key] = renderPipeline;
        return renderPipeline;
    }
}









- (id<MTLSamplerState>)samplerWithSamplerOptions:(PPPMTLSamplerOptions *)options {
    NSString *key = [NSString stringWithFormat:@"%lu_%lu_%lu_%lu_%lu", (unsigned long)options.minFilter, (unsigned long)options.magFilter, (unsigned long)options.mipFilter, (unsigned long)options.sAddressMode, (unsigned long)options.tAddressMode];
    
    if (self.samplerStateCache[key]) {
        return self.samplerStateCache[key];
    } else {
        MTLSamplerDescriptor *desc = [[MTLSamplerDescriptor alloc] init];
        desc.minFilter = options.minFilter;
        desc.magFilter = options.magFilter;
        desc.mipFilter = options.mipFilter;
        desc.sAddressMode = options.sAddressMode;
        desc.tAddressMode = options.tAddressMode;
//        desc.maxAnisotropy    = 1U; // 各向异性mipmap 一般不用考虑
//        desc.lodMinClamp      = 0.0f;
//        desc.lodMaxClamp      = FLT_MAX;
        id <MTLSamplerState> sampler = [self.device newSamplerStateWithDescriptor:desc];
        
        self.samplerStateCache[key] = sampler;
        return sampler;
    }
}




- (void)clear {
    self.renderer = nil;
    self.size = CGSizeZero;
    [self.renderPipelineCache removeAllObjects];
    [self.samplerStateCache removeAllObjects];
}


- (MTL3DRenderProcessor *)renderProcesser:(CGSize)renderSize {
    if (self.renderer && CGSizeEqualToSize(self.size, renderSize)) {
        return self.renderer;
    } else {
        MTL3DRenderProcessor *mvpRenderNode = [MTL3DRenderProcessor renderNode:renderSize];
        self.renderer = mvpRenderNode;
        self.size = renderSize;
        return mvpRenderNode;
    }
}



- (void)finish {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}









- (id<MTLBuffer>)buffer {
    typedef struct
    {
        matrix_float4x2 possa;
    } posaa;
    
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(vector_float2) * 4 options:MTLResourceStorageModeShared];
    
    posaa *uniforms = (posaa *)buffer.contents;
    
    matrix_float4x2 aa = {{
        {-1.0,  1.0},
        { 1.0,  1.0},
        {-1.0, -1.0},
        { 1.0, -1.0},
    }};
    
    uniforms->possa = aa;
    
    return buffer;
}


+ (const vector_float2 *)defaultPosition {
    static const vector_float2 pos[] = {
        {-1.0,  1.0},
        { 1.0,  1.0},
        {-1.0, -1.0},
        { 1.0, -1.0},
    };
    return pos;
}

+ (const vector_float2 *)textureCoordinates {
    static const vector_float2 Up[] = {
        {0.0f, 0.0f},
        {1.0f, 0.0f},
        {0.0f, 1.0f},
        {1.0f, 1.0f},
    };
    return Up;
}

// 默认倒置一下纹理 纹理左上角才是 0 0 但是渲染窗口左上角是 -1 1
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






