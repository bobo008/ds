
#import "THBTBNTestRenderer.h"


#import "THBTBNTestRenderNode.h"


#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

#define EqualZero(x) ((fabs((x))-0.0)<1e-6)

#define DEG2RAD(x) ((x) * M_PI / 180.0)

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


static float FOV = 22.5;


typedef struct THBVertexData {
    vector_float3 position;
    vector_float3 normal;
    vector_float2 texcoord;
} THBVertexData;



@interface THBTBNTestRenderer () {
    THBPixelBufferPoolAdaptor *_pixelPool;
    CVOpenGLESTextureCacheRef _coreTextureCache;
    
    
    GLuint _vao;
    GLuint _vbo;
    GLuint _ebo;
    
    THBGLESTexture *_imageTexture;
    
    THBGLESTexture *_normalTexture;
}



@property (nonatomic, assign) THBVertexData *vertices;

@end

@implementation THBTBNTestRenderer

#pragma mark -
- (void)setup {
    _pixelPool = [THBPixelBufferPoolAdaptor adaptor];
    _coreTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ipad_1.png" ofType:nil];
    _imageTexture = [self textureForMatrialPath:path];
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"resultImage_2.png" ofType:nil];
    _normalTexture = [self textureForMatrialPath:path2];

    _scale = 1;
    
}

- (void)dispose {
    @autoreleasepool {
        _pixelPool = nil;
        _coreTextureCache = nil;
        [_imageTexture releaseGLESTexture];
        _imageTexture = nil;
    }
}

#pragma mark -
- (THBPixelBufferPoolAdaptor *)pixelPool {
    return _pixelPool;
}


#pragma mark -
- (THBGLESTexture *)textureForMatrialPath:(NSString *)path {
    CVPixelBufferRef pixelBuffer = [THBPixelBufferUtil pixelBufferForLocalURL:[NSURL fileURLWithPath:path]];
    if (pixelBuffer) {
        CVOpenGLESTextureRef glTexture = [THBPixelBufferUtil textureForPixelBuffer:pixelBuffer glTextureCache:_coreTextureCache];
        if (!glTexture) {
            CVPixelBufferRelease(pixelBuffer);
        } else {

            return [THBGLESTexture createTextureWithPixel:pixelBuffer texture:glTexture];
        }
    }
    
    return nil;
}

- (nullable THBGLESTexture *)createGlesTextureWithWidth:(size_t)widthInPixels andHeight:(size_t)heightInPixels {
    return [self createCxxTextureWithWidth:widthInPixels andHeight:heightInPixels format:kCVPixelFormatType_32BGRA];
}

- (nullable THBGLESTexture *)createCxxTextureWithWidth:(size_t)widthInPixels andHeight:(size_t)heightInPixels format:(OSType)format {
    CVPixelBufferRef pixel = [_pixelPool pixelBufferWithSize:CGSizeMake(widthInPixels, heightInPixels) formatType:format];
    if (pixel) {
        CVOpenGLESTextureRef texture = [THBPixelBufferUtil textureForPixelBuffer:pixel glTextureCache:_coreTextureCache];
        if (texture) {
            return [THBGLESTexture createTextureWithPixel:pixel texture:texture];;
        } else {
            CVPixelBufferRelease(pixel);
        }
    }
    return nil;
}


#pragma mark -


- (THBGLESTexture *)drawCanvas {
    [self.pixelPool enter];

    THBGLESTexture *canvasGlesTexture; {
        int canvasWidth = 1000;
        int canvasHeight = 1000;
        canvasGlesTexture = [self createGlesTextureWithWidth:canvasWidth andHeight:canvasHeight];
    }
    if (!canvasGlesTexture) return nil;
    
    


    [self aaa];

    
    THBTBNTestRenderNode *renderNode = [[THBTBNTestRenderNode alloc] init];
    renderNode.outputTexture = canvasGlesTexture;
    [renderNode prepareRender];

    renderNode.inputTexture = _imageTexture;
    renderNode.inputTexture2 = _normalTexture;
    
    renderNode.vertexArrayBuffer = _vao;
    renderNode.indexElementBuffer = _ebo;
    renderNode.indexElementCount = 6;
    
    renderNode.pMatrix = [self obtainP];
    renderNode.vMatrix = [self obtainV];
    renderNode.mMatrix = [self obtainM];
    
    
    
    renderNode.tbnMatrix = simd_transpose((simd_mul([self obtainM], [self obtainTBN])));
    
    
//    renderNode.tbnMatrix = [self obtainTBN];
    
    
    simd_float3 cameraPos = simd_make_float3(0, 0, 1.0 / tan(FOV));
    renderNode.cameraPos = cameraPos;
    
    
    [renderNode render];


    [renderNode destroyRender];

    glFinish();

    [self.pixelPool leave];
    
    return canvasGlesTexture;
}




- (void)bbb {
    glDeleteVertexArrays(1, &_vao);
    glDeleteBuffers(1, &_vbo);
    glDeleteBuffers(1, &_ebo);
}


- (void)aaa {

    self.vertices = malloc(sizeof(THBVertexData) * 4);
    
    //3.初始化顶点(0,1,2,3)的顶点坐标以及纹理坐标
    self.vertices[0] = (THBVertexData){{-1, 1, 0},{0, 0, 1}, {0, 1}};
    self.vertices[1] = (THBVertexData){{-1, -1, 0},{0, 0, 1}, {0, 0}};
    self.vertices[2] = (THBVertexData){{1, 1, 0}, {0, 0, 1}, {1, 1}};
    self.vertices[3] = (THBVertexData){{1, -1, 0}, {0, 0, 1}, {1, 0}};
    
    
    GLvoid *vertexData = self.vertices;
    NSUInteger dataSize = sizeof(THBVertexData) * 4;
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, dataSize, vertexData, GL_STATIC_DRAW);
    
    free(self.vertices);
    

    
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(THBVertexData), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(THBVertexData), BUFFER_OFFSET(offsetof(THBVertexData, texcoord)));
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(THBVertexData), BUFFER_OFFSET(offsetof(THBVertexData, normal)));
    glEnableVertexAttribArray(2);
    
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    
    GLuint indices[] = {0, 1, 2, 1, 2, 3};
    
    NSUInteger indexBufferSize = sizeof(uint32_t) * 6;
    
    glGenBuffers(1, &_ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexBufferSize, indices, GL_STATIC_DRAW);


    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}



- (simd_float4x4)obtainP {
    simd_float4x4 mProj = [self projectionMatrixWithCanvasWidth:1000 canvasHeight:1000];
    return mProj;
}



- (simd_float4x4)obtainV {
    simd_float4x4 mView = [self viewMatrixWithCanvasWidth:1000 canvasHeight:1000];
    return mView;
}



- (simd_float4x4)obtainM {
    simd_float4x4 mModel = ({
        float scale = self.scale;
        simd_float4x4 mScale = {
            simd_make_float4(scale, 0, 0, 0),
            simd_make_float4(0, scale, 0, 0),
            simd_make_float4(0, 0, scale, 0),
            simd_make_float4(0, 0, 0, 1),
        };

        simd_float4x4 mRotate = [self x:self.x y:self.y z:self.z];
        
        simd_float4x4 mTranslate = {
            simd_make_float4(1, 0, 0, 0),
            simd_make_float4(0, 1, 0, 0),
            simd_make_float4(0, 0, 1, 0),
            simd_make_float4(0, 0, -1, 1),
        };
        
        simd_mul(simd_mul(mTranslate, mRotate), mScale);
    });
    return mModel;
}


- (simd_float4x4)obtainTBN {
    simd_float4x4 TBN = { /// 因为切线空间 T B 直接可以用1  0  0 1
        simd_make_float4(1, 0, 0, 0),
        simd_make_float4(0, 1, 0, 0),
        simd_make_float4(0, 0, 1, 0),
        simd_make_float4(0, 0, 0, 1),
    };
    
    return TBN;
}






- (simd_float4x4)x:(float)x y:(float)y z:(float)z {
    
    
    const float cosThetaX = cos(x);
    const float sinThetaX = sin(x);
    simd_float4x4 matrixX = {
        simd_make_float4(1,0,0, 0),
        simd_make_float4(0,cosThetaX,-sinThetaX, 0),
        simd_make_float4(0,sinThetaX,cosThetaX, 0),
        simd_make_float4(0,0,0, 1)
    };


    const float cosThetaY = cos(y);
    const float sinThetaY = sin(y);
    simd_float4x4 matrixY = {
        simd_make_float4(cosThetaY,0,-sinThetaY, 0),
        simd_make_float4(0,1,0, 0),
        simd_make_float4(sinThetaY,0,cosThetaY, 0),
        simd_make_float4(0,0,0, 1)
    };

    const float cosThetaZ = cos(z);
    const float sinThetaZ = sin(z);
    simd_float4x4 matrixZ = {
        simd_make_float4(cosThetaZ,-sinThetaZ,0,0),
        simd_make_float4(sinThetaZ,cosThetaZ,0, 0),
        simd_make_float4(0,0,1,0),
        simd_make_float4(0,0,0,1)
    };
    

    
    return simd_mul(simd_mul(simd_transpose(matrixX), simd_transpose(matrixY)), simd_transpose(matrixZ));
}





- (simd_float4x4)viewMatrixWithCanvasWidth:(size_t)canvasWidth canvasHeight:(size_t)canvasHeight {

    simd_float3 cameraPos = simd_make_float3(0, 0, 1.0 / tan(FOV));
    simd_float4x4 posMatrix = {
        simd_make_float4(1,0,0, 0),
        simd_make_float4(0,1,0, 0),
        simd_make_float4(0,0,1, 0),
        simd_make_float4(-cameraPos.x,-cameraPos.y,-cameraPos.z,1),
    };
    simd_float4x4 viewMatrix = {
        ///              x   y  z  w
        simd_make_float4(1,0,0,0),
        simd_make_float4(0,1,0,0),
        simd_make_float4(0,0,1,0),
        simd_make_float4(0,0,0,1),
    };
    return simd_mul(viewMatrix , posMatrix);
}




- (simd_float4x4)projectionMatrixWithCanvasWidth:(size_t)canvasWidth canvasHeight:(size_t)canvasHeight {
    
    const CGFloat n = 0.1;
    const CGFloat f = 1000.0;
    const CGFloat r = n * tan(FOV);
    const CGFloat t = r * (CGFloat)canvasHeight / (CGFloat)canvasWidth;
    simd_float4x4 projectionMatrix = {
        simd_make_float4(n/r, 0, 0, 0),
        simd_make_float4(0, n/t, 0, 0),
        simd_make_float4(0, 0, -(f+n)/(f-n), -1),
        simd_make_float4(0, 0, -2*f*n/(f-n), 0),
    };
    return projectionMatrix;
}



- (void)TBN {
    simd_float2 B = simd_make_float2(0,0.5);
    simd_float2 A = simd_make_float2(0.5,0);
    simd_float2 C = simd_make_float2(1,0.6);
    
    simd_float2 edge1 = C - A;//E1
    simd_float2 edge2 = B - A;//E2
    simd_float2 uv1 = C - A;//纹理坐标向量
    simd_float2 uv2 = B - A;//纹理坐标向量

    simd_float2x2 T2 = {
        simd_make_float2(uv1.x, uv1.y),
        simd_make_float2(uv2.x, uv2.y),
    };
    
    simd_float2x3 TTT2 = {
        simd_make_float3(edge1, 0),
        simd_make_float3(edge2, 0),
    };

    simd_float3x2 ret2 = simd_mul(simd_inverse(simd_transpose(T2)),simd_transpose(TTT2));
}




@end
