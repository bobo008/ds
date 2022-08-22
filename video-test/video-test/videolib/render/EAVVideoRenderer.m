

#import "EAVVideoRenderer.h"
#import "THBContext.h"

#import "EAVYUV2RGBRenderNode.h"



#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

#ifdef DEBUG
#define COST_TIME_CALC_BEGIN        CFTimeInterval _cost_time_begin = CACurrentMediaTime();
#define COST_TIME_CALC_RESET        _cost_time_begin = CACurrentMediaTime();
#define COST_TIME_CALC_ENDED(x)     NSLog(@"%@: %f", (x), CACurrentMediaTime() - _cost_time_begin);
#else
#define COST_TIME_CALC_BEGIN
#define COST_TIME_CALC_RESET
#define COST_TIME_CALC_ENDED(x)
#endif

@implementation EAVVideoRenderer

- (instancetype)init {
    if (self = [super init]) {        
        [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
            [GPUImageContext useImageProcessingContext];
            
            self->_pixelPool = [THBPixelBufferPoolAdaptor adaptor];
            
            glGenFramebuffers(1, &self->_framebufferHandle);
            glBindFramebuffer(GL_FRAMEBUFFER, self->_framebufferHandle);
        }];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
    
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        [GPUImageContext useImageProcessingContext];
        glFinish();
        
        glDeleteFramebuffers(1, &self->_framebufferHandle);
        self->_framebufferHandle = 0;
        

        
        self->_pixelPool = nil;
        
    }];
}



#pragma mark - Public
- (CVPixelBufferRef)renderWithRequest:(AVAsynchronousVideoCompositionRequest *)request {
//    self.request = request;
//    self.renderContext = request.renderContext;
//    return [self render];
    
    
    GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
    [glContext useAsCurrentContext];
    
    [self beforeRender];
    

    CMPersistentTrackID composeTrackID = [[self.renderComposeTrackIdMap objectForKey:@"fullmoon_01"] intValue];
    CVPixelBufferRef movieFrame = [request sourceFrameByTrackID:composeTrackID]; /// 这个方法取出来的 movieFrame不会retain 所以不用release
    
    
    int movieWidth = (int) CVPixelBufferGetWidth(movieFrame);
    int movieHeight = (int) CVPixelBufferGetHeight(movieFrame);


    THBTexture *texture = [self createTextureWithSize:CGSizeMake(movieWidth, movieHeight)];
    
    EAVYUV2RGBRenderNode *node = [EAVYUV2RGBRenderNode renderNode];
    node.outputTexture = texture;
    node.framebufferHandle = self.framebufferHandle;
    node.movieFrame = movieFrame;
    [node render];
    
    glFlush();
//    glFinish();
    
    CFRelease(texture.texture);
    
    [self afterRender];
    
    return texture.pixel;
}

- (void)beforeRender {
    [_pixelPool enter];

}

- (void)afterRender {

    [_pixelPool leave];

}


- (float *)defaultPositions {
    float *positions = calloc(4 * 3, sizeof(float));
    positions[0] = -1; positions[1] = 1; positions[2] = 0;
    positions[3] = 1; positions[4] = 1; positions[5] = 0;
    positions[6] = -1; positions[7] = -1; positions[8] = 0;
    positions[9] = 1; positions[10] = -1; positions[11] = 0;
    return positions;
}





#pragma mark - Private


//- (THBTexture *)createCanvasTexture {
//    CVPixelBufferRef pixels = [_pixelPool pixelBufferWithSize:_renderContext.size];
//    CVOpenGLESTextureCacheRef glTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
//    CVOpenGLESTextureRef texture = [THBPixelBufferUtil textureForPixelBuffer:pixels glTextureCache:glTextureCache];
//    
//    THBTexture *eavTexture = [THBTexture createTextureWithPixel:pixels texture:texture];
//    return eavTexture;
//}



#pragma mark - Tool
- (THBTexture *)createTextureWithSize:(CGSize)size {
    THBPixelBufferPoolAdaptor *pixelPool = self.pixelPool;
    CVOpenGLESTextureCacheRef glTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
    CVPixelBufferRef pixels = [pixelPool pixelBufferWithSize:size];
    CVOpenGLESTextureRef glTexture = [THBPixelBufferUtil textureForPixelBuffer:pixels glTextureCache:glTextureCache];
    
    THBTexture *eavTexture = [THBTexture createTextureWithPixel:pixels texture:glTexture];
    return eavTexture;
}

@end
