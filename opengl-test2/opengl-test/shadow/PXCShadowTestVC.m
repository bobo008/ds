//
//  PXCShadowTestVC.m
//  PXCEditor
//
//  Created by guangzhuiyuandev on 2022/1/24.
//

#import "PXCShadowTestVC.h"

#import "THBContext.h"
#import "THBGLESTexture.h"

//#import "GPUImageContext.h"
#import "THBPixelBufferUtil.h"
//#import "PXCCameraDisplayView.h"
#import "THBPixelBufferPoolAdaptor.h"

#import "CXXFillColorRenderNode.h"

#import <simd/simd.h>
#import <OpenGLES/ES3/gl.h>




static NSString * const shadowVs = SHADER_STRING
(
 
 attribute highp vec4 position;
 attribute highp vec4 inputTextureCoordinate;

 varying highp vec2 textureCoordinate;

 varying highp float aaa;
 
 uniform highp mat4 model;
 uniform highp mat4 view;
 uniform highp mat4 projection;

 void main()
 {
     gl_Position = projection * view * model * position;
     aaa = (gl_Position.z / gl_Position.w + 1.0)/ 2.0;
     textureCoordinate = inputTextureCoordinate.xy;
 }

 );

static NSString * const shadowFs = SHADER_STRING
(


 
 varying highp float aaa;
 varying highp vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;


 void main() {
    gl_FragColor = vec4(aaa,aaa,aaa,1.0);
    
//    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);

 }
 );


static NSString * const shadowVs2 = SHADER_STRING
(
 
 attribute highp vec4 position;
 attribute highp vec4 position2;
 attribute highp vec4 position3;
 attribute highp vec4 inputTextureCoordinate;

 varying highp vec2 textureCoordinate;
 varying highp vec4 textureCoordinate2;
 varying highp float aaa;
 
 uniform highp mat4 model;
 uniform highp mat4 view;
 uniform highp mat4 projection;
 
 uniform highp mat4 model2;
 uniform highp mat4 view2;
 uniform highp mat4 projection2;
 


 void main()
 {
//    gl_Position = position3;
//    aaa = (gl_Position.z / gl_Position.w + 1.0)/ 2.0;
    
     gl_Position = projection * view * model * position;
    textureCoordinate = inputTextureCoordinate.xy;

    highp vec4  ass =  projection2 * view2 * model2 * position2;
    aaa = (ass.z / ass.w + 1.0)/ 2.0;
    textureCoordinate2 = position3;
//    vec2(ass.x / ass.w * 0.5 + 0.5,ass.y / ass.w * 0.5 + 0.5);
 }

 );

static NSString * const shadowFs2 = SHADER_STRING
(


 varying highp float aaa;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 varying highp vec4 textureCoordinate2;
 uniform sampler2D inputImageTexture2;


 void main() {
//    highp vec2 adaa = vec2(textureCoordinate2.x / textureCoordinate2.w * 0.5 + 0.5,textureCoordinate2.y / textureCoordinate2.w * 0.5 + 0.5);
//    highp vec4 aaaa = texture2D(inputImageTexture2, adaa);
//    gl_FragColor = aaaa;
    
    
    highp vec2 adaa = vec2(textureCoordinate2.x / textureCoordinate2.w * 0.5 + 0.5,textureCoordinate2.y / textureCoordinate2.w * 0.5 + 0.5);
    highp vec4 aaaa = texture2D(inputImageTexture2, adaa);
    if(aaaa.g - aaa < (10. / 255.) && aaaa.g - aaa > (-10. / 255.)) {/// 效果不太对劲，不应该用这个存，应该用每个比特存8位再读出来，精度太辣鸡
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    } else {
        gl_FragColor = vec4(0.,0.,0.,1.);
    }

 }


 
 );




static const float FOV = 45.0 * M_PI / 180.0;


static simd_float4x4 getViewMatrix(size_t canvasWidth, size_t canvasHeight) {
    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth, 0.5 * canvasHeight, 0.5 * canvasWidth * 1.0 / tan(FOV));
    simd_float4x4 posMatrix = {
        simd_make_float4(1,0,0,-cameraPos.x),
        simd_make_float4(0,1,0,-cameraPos.y),
        simd_make_float4(0,0,1,-cameraPos.z),
        simd_make_float4(0,0,0,1),
    };
    simd_float4x4 viewMatrix = {
        simd_make_float4(1,0,0,0),
        simd_make_float4(0,1,0,0),
        simd_make_float4(0,0,1,0),
        simd_make_float4(0,0,0,1),
    };
    
    return simd_mul(viewMatrix, posMatrix);;
}

static simd_float4x4 getProjectionMatrix(size_t canvasWidth, size_t canvasHeight) {
    const CGFloat n = 1.0;
    const CGFloat f = 2000.0;
    const CGFloat r = n * tan(FOV);
    const CGFloat t = r * (CGFloat)canvasHeight / (CGFloat)canvasWidth;
    simd_float4x4 projectionMatrix = {
        simd_make_float4(n/r, 0, 0, 0),
        simd_make_float4(0, n/t, 0, 0),
        simd_make_float4(0, 0, -(f+n)/(f-n), -2*f*n/(f-n)),
        simd_make_float4(0, 0, -1, 0),
    };
    return projectionMatrix;
}


static simd_float4x4 getViewMatrix2(size_t canvasWidth, size_t canvasHeight) {
//    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth * 0.5, canvasHeight, 0.5 * canvasWidth * 0.5);
//    simd_float4x4 posMatrix = {
//        simd_make_float4(1,0,0,-cameraPos.x),
//        simd_make_float4(0,1,0,-cameraPos.y),
//        simd_make_float4(0,0,1,-cameraPos.z),
//        simd_make_float4(0,0,0,1),
//    };
//
//    simd_float4x4 viewMatrix = {
//        simd_make_float4(sqrt(0.5),0,sqrt(0.5),0),
//        simd_make_float4(sqrt(0.25),sqrt(0.5),-sqrt(0.25),0),
//        simd_make_float4(-sqrt(0.25),sqrt(0.5),sqrt(0.25),0),
//        simd_make_float4(0,0,0,1),
//    };
    
//    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth * 0.5, 0.5 * canvasHeight, 0.5 * canvasWidth * 0.5);
//    simd_float4x4 posMatrix = {
//        simd_make_float4(1,0,0,-cameraPos.x),
//        simd_make_float4(0,1,0,-cameraPos.y),
//        simd_make_float4(0,0,1,-cameraPos.z),
//        simd_make_float4(0,0,0,1),
//    };
//
//    simd_float4x4 viewMatrix = {
//        simd_make_float4(sqrt(0.5),0,sqrt(0.5),0),
//        simd_make_float4(0,1,0,0),
//        simd_make_float4(-sqrt(0.5),0,sqrt(0.5),0),
//        simd_make_float4(0,0,0,1),
//    };

    
    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth, 0.75 * canvasHeight, 0.25 * canvasWidth);
    simd_float4x4 posMatrix = {
        simd_make_float4(1,0,0,-cameraPos.x),
        simd_make_float4(0,1,0,-cameraPos.y),
        simd_make_float4(0,0,1,-cameraPos.z),
        simd_make_float4(0,0,0,1),
    };

    simd_float4x4 viewMatrix = {
        simd_make_float4(1,0,0,0),
        simd_make_float4(0,sqrt(0.5),-sqrt(0.5),0),
        simd_make_float4(0,sqrt(0.5),sqrt(0.5),0),
        simd_make_float4(0,0,0,1),
    };
    

    return simd_mul(posMatrix,viewMatrix);
}


static simd_float4x4 getProjectionMatrix2(size_t canvasWidth, size_t canvasHeight) {
    const CGFloat n = 0.01;
    const CGFloat f = 2000.0;
    const CGFloat r = canvasWidth / 2.0;
    const CGFloat t = canvasHeight / 2.0;
    simd_float4x4 projectionMatrix = {
        simd_make_float4(1/r, 0, 0, 0),
        simd_make_float4(0, 1/t, 0, 0),
        simd_make_float4(0, 0, -2/(f-n), -(f+n)/(f-n)),
        simd_make_float4(0, 0, 0, 1),
    };
    return projectionMatrix;
}


static THBGLESTexture * _Nullable GLESTextureFromPixel(CVPixelBufferRef _Nullable pixel) {
    if (pixel) {
        GPUImageContext *ctx = [GPUImageContext sharedImageProcessingContext];
        CVOpenGLESTextureRef texture = [THBPixelBufferUtil textureForPixelBuffer:pixel glTextureCache:ctx.coreVideoTextureCache];
        if (texture) {
            return [THBGLESTexture createTextureWithPixel:pixel texture:texture];
        } else {
            CVPixelBufferRelease(pixel);
        }
    }
    return nil;
}

static THBGLESTexture * _Nullable GLESTextureFromImage(UIImage * _Nullable image) {
    if (image.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    CVPixelBufferRef pixel = [THBPixelBufferUtil pixelBufferForImage:image];
    return GLESTextureFromPixel(pixel);
}




@interface PXCShadowTestVC () {
    GLuint _framebuffer;
    THBPixelBufferPoolAdaptor *_pixelPool;
    CVOpenGLESTextureCacheRef _coreTextureCache;
}
//@property (nonatomic) PXCCameraDisplayView *dispalyer;
@end

@implementation PXCShadowTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        [GPUImageContext useImageProcessingContext];
        GLuint framebuffer;
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        self->_framebuffer = framebuffer;
        self->_pixelPool = [THBPixelBufferPoolAdaptor adaptor];
        self->_coreTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
        
        [self->_pixelPool enter];
    }];
    

//    PXCCameraDisplayView *view = [[PXCCameraDisplayView alloc] initWithFrame:CGRectMake(0, 64, 375, 375)];
//
//    view.transform = CGAffineTransformScale(view.transform, 1.0, -1.0);
//    [self.view addSubview:view];
//    self.dispalyer = view;
    
    
    

    UIImage *image = [UIImage imageNamed:@"ipad_1"];
    
    THBGLESTexture *texture = GLESTextureFromImage(image);
    THBGLESTexture *texture2 = GLESTextureFromImage(image);
    THBGLESTexture *texture3 = GLESTextureFromImage(image);
    
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{

        GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
        [glContext useAsCurrentContext];
        glBindFramebuffer(GL_FRAMEBUFFER, self->_framebuffer);
        glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(texture2.pixel), (GLsizei)CVPixelBufferGetHeight(texture2.pixel));
        glFramebufferTexture2D(GL_FRAMEBUFFER,
                               GL_COLOR_ATTACHMENT0,
                               CVOpenGLESTextureGetTarget(texture2.texture),
                               CVOpenGLESTextureGetName(texture2.texture),
                               0);
        
        glClearColor(0., 0, 0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        
        GLProgram *glProgram = [self glProgram];
        [glContext setContextShaderProgram:glProgram];
        
        {
            simd_float4x4 positionMatix = {
                simd_make_float4(-1000, -1000, 0, 1),
                simd_make_float4( 1000, -1000, 0, 1),
                simd_make_float4(-1000,  1000, 0, 1),
                simd_make_float4( 1000,  1000, 0, 1),
            };


            GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
            glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix);
            glEnableVertexAttribArray(attributePositionIndex);

            GLfloat locations[] = {0 ,1 ,1 , 1 , 0 , 0 , 1 , 0,};

            GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
            glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, (GLfloat *)locations);
            glEnableVertexAttribArray(attributeTexCoordIndex);

            simd_float4x4 modelMatix = {
                simd_make_float4(1, 0, 0, 1000),
                simd_make_float4(0, 1, 0, 1000),
                simd_make_float4(0, 0, 1, 0),
                simd_make_float4(0, 0, 0, 1),
            };

            simd_float4x4 modelMatix2 = simd_transpose(modelMatix);

            GLuint model = [glProgram uniformIndex:@"model"];
            glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatix2);

            simd_float4x4 viewMatix = simd_transpose(getViewMatrix2(2000, 2000));
            GLuint view = [glProgram uniformIndex:@"view"];
            glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatix);


            simd_float4x4 projectionMatix = simd_transpose(getProjectionMatrix2(2000, 2000));
            GLuint projection = [glProgram uniformIndex:@"projection"];
            glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatix);



            glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
            glActiveTexture(GL_TEXTURE0);

            glBindTexture(CVOpenGLESTextureGetTarget(texture.texture), CVOpenGLESTextureGetName(texture.texture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        }
        {
            
            simd_float4x4 positionMatix = {
                simd_make_float4(-300 , -300, 500, 1),
                simd_make_float4( 300, -300, 500, 1),
                simd_make_float4(-300,  300, 500, 1),
                simd_make_float4( 300,  300, 500, 1),
            };
            
            
            GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
            glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix);
            glEnableVertexAttribArray(attributePositionIndex);
            
            GLfloat locations[] = {0 ,1 ,1 , 1 , 0 , 0 , 1 , 0,};
            
            GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
            glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, (GLfloat *)locations);
            glEnableVertexAttribArray(attributeTexCoordIndex);
            
            simd_float4x4 modelMatix = {
                simd_make_float4(1, 0, 0, 1000),
                simd_make_float4(0, 1, 0, 1000),
                simd_make_float4(0, 0, 1, 0),
                simd_make_float4(0, 0, 0, 1),
            };
            
            simd_float4x4 modelMatix2 = simd_transpose(modelMatix);
            
            GLuint model = [glProgram uniformIndex:@"model"];
            glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatix2);
            
            simd_float4x4 viewMatix = simd_transpose(getViewMatrix2(2000, 2000));
            GLuint view = [glProgram uniformIndex:@"view"];
            glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatix);
            
            
            simd_float4x4 projectionMatix = simd_transpose(getProjectionMatrix2(2000, 2000));
            GLuint projection = [glProgram uniformIndex:@"projection"];
            glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatix);
            
            simd_float4x4 aa = simd_mul(modelMatix2, positionMatix);
            simd_float4x4 aaa = simd_mul(viewMatix, aa);
//            simd_float4x4 aaaa = simd_mul(projectionMatix, aaa);
            
            glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
            glActiveTexture(GL_TEXTURE0);
            
            glBindTexture(CVOpenGLESTextureGetTarget(texture.texture), CVOpenGLESTextureGetName(texture.texture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
        }
        glFinish();
        
        {
            glBindFramebuffer(GL_FRAMEBUFFER, self->_framebuffer);
            glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(texture3.pixel), (GLsizei)CVPixelBufferGetHeight(texture3.pixel));
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                                   GL_COLOR_ATTACHMENT0,
                                   CVOpenGLESTextureGetTarget(texture3.texture),
                                   CVOpenGLESTextureGetName(texture3.texture),
                                   0);

            glClearColor(0., 0, 0, 0.0);
            glClear(GL_COLOR_BUFFER_BIT);


            GLProgram *glProgram = [self glProgram2];
            [glContext setContextShaderProgram:glProgram];



            {
                simd_float4x4 positionMatix = {
                    simd_make_float4(-1000, -1000, 0, 1),
                    simd_make_float4( 1000, -1000, 0, 1),
                    simd_make_float4(-1000,  1000, 0, 1),
                    simd_make_float4( 1000,  1000, 0, 1),
                };


                GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
                glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix);
                glEnableVertexAttribArray(attributePositionIndex);


                simd_float4x4 positionMatix2 = {
                    simd_make_float4(-1000, -1000, 0, 1),
                    simd_make_float4( 1000, -1000, 0, 1),
                    simd_make_float4(-1000,  1000, 0, 1),
                    simd_make_float4( 1000,  1000, 0, 1),
                };

                GLuint attributePositionIndex2 = [glProgram attributeIndex:@"position2"];
                glVertexAttribPointer(attributePositionIndex2, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix2);
                glEnableVertexAttribArray(attributePositionIndex2);


                GLfloat locations[] = {0 ,1 ,1 , 1 , 0 , 0 , 1 , 0,};

                GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
                glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, (GLfloat *)locations);
                glEnableVertexAttribArray(attributeTexCoordIndex);

                simd_float4x4 modelMatix = {
                    simd_make_float4(1, 0, 0, 1000),
                    simd_make_float4(0, 1, 0, 1000),
                    simd_make_float4(0, 0, 1, 0),
                    simd_make_float4(0, 0, 0, 1),
                };

                simd_float4x4 modelMatix2 = simd_transpose(modelMatix);
                GLuint model = [glProgram uniformIndex:@"model"];
                glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatix2);

                simd_float4x4 viewMatix = simd_transpose(getViewMatrix(2000, 2000));
                GLuint view = [glProgram uniformIndex:@"view"];
                glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatix);


                simd_float4x4 projectionMatix = simd_transpose(getProjectionMatrix(2000, 2000));
                GLuint projection = [glProgram uniformIndex:@"projection"];
                glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatix);

                simd_float4x4 modelMatix222 = {
                    simd_make_float4(1, 0, 0, 1000),
                    simd_make_float4(0, 1, 0, 1000),
                    simd_make_float4(0, 0, 1, 0),
                    simd_make_float4(0, 0, 0, 1),
                };

                simd_float4x4 modelMatix22 = simd_transpose(modelMatix222);
                GLuint model2 = [glProgram uniformIndex:@"model2"];
                glUniformMatrix4fv(model2, 1, GL_FALSE, (GLfloat *)&modelMatix22);


                simd_float4x4 viewMatix2 = simd_transpose(getViewMatrix2(2000, 2000));
                GLuint view2 = [glProgram uniformIndex:@"view2"];
                glUniformMatrix4fv(view2, 1, GL_FALSE, (GLfloat *)&viewMatix2);


                simd_float4x4 projectionMatix2 = simd_transpose(getProjectionMatrix2(2000, 2000));
                GLuint projection2 = [glProgram uniformIndex:@"projection2"];
                glUniformMatrix4fv(projection2, 1, GL_FALSE, (GLfloat *)&projectionMatix2);

                simd_float4x4 aa = simd_mul(modelMatix22, positionMatix2);
                simd_float4x4 aaa = simd_mul(viewMatix2, aa);
                simd_float4x4 aaaa = simd_mul(projectionMatix2, aaa);

                GLuint attributePositionIndex3 = [glProgram attributeIndex:@"position3"];
                glVertexAttribPointer(attributePositionIndex3, 4, GL_FLOAT, 0, 0, (GLfloat *)&aaaa);
                glEnableVertexAttribArray(attributePositionIndex3);


                glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(CVOpenGLESTextureGetTarget(texture.texture), CVOpenGLESTextureGetName(texture.texture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


                glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE2], 1);
                glActiveTexture(GL_TEXTURE1);
                glBindTexture(CVOpenGLESTextureGetTarget(texture2.texture), CVOpenGLESTextureGetName(texture2.texture));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            }
        }
        
        {
            glBindFramebuffer(GL_FRAMEBUFFER, self->_framebuffer);
            glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(texture3.pixel), (GLsizei)CVPixelBufferGetHeight(texture3.pixel));
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                                   GL_COLOR_ATTACHMENT0,
                                   CVOpenGLESTextureGetTarget(texture3.texture),
                                   CVOpenGLESTextureGetName(texture3.texture),
                                   0);

//            glClearColor(0., 0, 0, 0.0);
//            glClear(GL_COLOR_BUFFER_BIT);


            GLProgram *glProgram = [self glProgram2];
            [glContext setContextShaderProgram:glProgram];

            simd_float4x4 positionMatix = {
                simd_make_float4(-300 , -300, 500, 1),
                simd_make_float4( 300, -300, 500, 1),
                simd_make_float4(-300,  300, 500, 1),
                simd_make_float4( 300,  300, 500, 1),
            };


            GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
            glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix);
            glEnableVertexAttribArray(attributePositionIndex);


            simd_float4x4 positionMatix2 = {
                simd_make_float4(-300 , -299.9, 500, 1),
                simd_make_float4( 300, -299.9, 500, 1),
                simd_make_float4(-300,  299.9, 500, 1),
                simd_make_float4( 300,  299.9, 500, 1),
            };

            GLuint attributePositionIndex2 = [glProgram attributeIndex:@"position2"];
            glVertexAttribPointer(attributePositionIndex2, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix2);
            glEnableVertexAttribArray(attributePositionIndex2);

            GLfloat locations[] = {0 ,1 ,1 , 1 , 0 , 0.5 , 1 , 0.5,};

            GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
            glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, (GLfloat *)locations);
            glEnableVertexAttribArray(attributeTexCoordIndex);

            simd_float4x4 modelMatix = {
                simd_make_float4(1, 0, 0, 1000),
                simd_make_float4(0, 1, 0, 1000),
                simd_make_float4(0, 0, 1, 0),
                simd_make_float4(0, 0, 0, 1),
            };

            simd_float4x4 modelMatix2 = simd_transpose(modelMatix);



            GLuint model = [glProgram uniformIndex:@"model"];
            glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatix2);

            simd_float4x4 modelMatix222 = {
                simd_make_float4(1, 0, 0, 1000),
                simd_make_float4(0, 1, 0, 1000),
                simd_make_float4(0, 0, 1, 0),
                simd_make_float4(0, 0, 0, 1),
            };

            simd_float4x4 modelMatix22 = simd_transpose(modelMatix222);
            GLuint model2 = [glProgram uniformIndex:@"model2"];
            glUniformMatrix4fv(model2, 1, GL_FALSE, (GLfloat *)&modelMatix22);


            simd_float4x4 viewMatix = simd_transpose(getViewMatrix(2000, 2000));
            GLuint view = [glProgram uniformIndex:@"view"];
            glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatix);


            simd_float4x4 projectionMatix = simd_transpose(getProjectionMatrix(2000, 2000));
            GLuint projection = [glProgram uniformIndex:@"projection"];
            glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatix);

            simd_float4x4 viewMatix2 = simd_transpose(getViewMatrix2(2000, 2000));
            GLuint view2 = [glProgram uniformIndex:@"view2"];
            glUniformMatrix4fv(view2, 1, GL_FALSE, (GLfloat *)&viewMatix2);


            simd_float4x4 projectionMatix2 = simd_transpose(getProjectionMatrix2(2000, 2000));
            GLuint projection2 = [glProgram uniformIndex:@"projection2"];
            glUniformMatrix4fv(projection2, 1, GL_FALSE, (GLfloat *)&projectionMatix2);

            simd_float4x4 aa = simd_mul(modelMatix22, positionMatix2);
            simd_float4x4 aaa = simd_mul(viewMatix2, aa);
            simd_float4x4 aaaa = simd_mul(projectionMatix2, aaa);



            GLuint attributePositionIndex3 = [glProgram attributeIndex:@"position3"];
            glVertexAttribPointer(attributePositionIndex3, 4, GL_FLOAT, 0, 0, (GLfloat *)&aaaa);
            glEnableVertexAttribArray(attributePositionIndex3);


            glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(CVOpenGLESTextureGetTarget(texture.texture), CVOpenGLESTextureGetName(texture.texture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE2], 1);
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(CVOpenGLESTextureGetTarget(texture2.texture), CVOpenGLESTextureGetName(texture2.texture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        }
        

        glFinish();
    }];
    
    
//    [self.dispalyer pixelBufferReady:texture3.pixel];
    
}










- (IBAction)onBack:(id)sender {
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        GLuint framebuffer = self->_framebuffer;
        glDeleteFramebuffers(1, &framebuffer);
        [self->_pixelPool leave];
        self->_framebuffer = 0;
        self->_pixelPool = nil;
        self->_coreTextureCache = nil;
    }];
    
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark -
- (GLProgram *)glProgram {
    static GLProgram *glProgram;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *attributeNames = @[
            CXX_GLSL_ATTRIBUTES_POSITION,
            CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE,
        ];
        glProgram = CXXLoadGLProgram(shadowVs, shadowFs, attributeNames);
    });
    return glProgram;
}


- (GLProgram *)glProgram2 {
    static GLProgram *glProgram;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *attributeNames = @[
            CXX_GLSL_ATTRIBUTES_POSITION,
            @"position2",
            @"position3",
            CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE,
        ];
        glProgram = CXXLoadGLProgram(shadowVs2, shadowFs2, attributeNames);
    });
    return glProgram;
}
@end








//
//
////
////  PXCShadowTestVC.m
////  PXCEditor
////
////  Created by guangzhuiyuandev on 2022/1/24.
////
//
//#import "PXCShadowTestVC.h"
//
//#import "CXXContext.h"
//#import "CXXGLESTexture.h"
//#import "CXXTextureUitl.h"
//#import "GPUImageContext.h"
//#import "CXXPixelBufferUtil.h"
//#import "PXCCameraDisplayView.h"
//#import "CXXPixelBufferPoolAdaptor.h"
//
//
//#import "CXXFillColorRenderNode.h"
//
//#import <simd/simd.h>
//#import <OpenGLES/ES3/gl.h>
//
//
//
//
//static NSString * const shadowVs = SHADER_STRING
//(
//
// attribute highp vec4 position;
// attribute highp vec4 inputTextureCoordinate;
//
// varying highp vec2 textureCoordinate;
//
//
// uniform highp mat4 model;
// uniform highp mat4 view;
// uniform highp mat4 projection;
//
// void main()
// {
//     gl_Position = projection * view * model * position;
////     gl_Position = position;
//     textureCoordinate = inputTextureCoordinate.xy;
// }
//
// );
//
//static NSString * const shadowFs = SHADER_STRING
//(
//
//
//
// varying highp vec2 textureCoordinate;
//
// uniform sampler2D inputImageTexture;
//
//
// void main() {
//     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
////     gl_FragColor = vec4(1.0,0.0,0.0,1.0);
// }
//
//
//
// );
//
//
//
//
//static const float FOV = 45.0 * M_PI / 180.0;
//
//
//static simd_float4x4 getViewMatrix(size_t canvasWidth, size_t canvasHeight) {
//    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth, 0.5 * canvasHeight, 0.5 * canvasWidth * 1.0 / tan(FOV));
//    simd_float4x4 posMatrix = {
//        simd_make_float4(1,0,0,-cameraPos.x),
//        simd_make_float4(0,1,0,-cameraPos.y),
//        simd_make_float4(0,0,1,-cameraPos.z),
//        simd_make_float4(0,0,0,1),
//    };
//    simd_float4x4 viewMatrix = {
//        simd_make_float4(1,0,0,0),
//        simd_make_float4(0,1,0,0),
//        simd_make_float4(0,0,1,0),
//        simd_make_float4(0,0,0,1),
//    };
//
//    return simd_mul(viewMatrix, posMatrix);;
//}
//
//static simd_float4x4 getProjectionMatrix(size_t canvasWidth, size_t canvasHeight) {
//    const CGFloat n = 1.0;
//    const CGFloat f = 100.0;
//    const CGFloat r = n * tan(FOV);
//    const CGFloat t = r * (CGFloat)canvasHeight / (CGFloat)canvasWidth;
//    simd_float4x4 projectionMatrix = {
//        simd_make_float4(n/r, 0, 0, 0),
//        simd_make_float4(0, n/t, 0, 0),
//        simd_make_float4(0, 0, -(f+n)/(f-n), -2*f*n/(f-n)),
//        simd_make_float4(0, 0, -1, 0),
//    };
//    return projectionMatrix;
//}
//
//
//static simd_float4x4 getViewMatrix2(size_t canvasWidth, size_t canvasHeight) {
////    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth * 0.5, canvasHeight, 0.5 * canvasWidth * 0.5);
////    simd_float4x4 posMatrix = {
////        simd_make_float4(1,0,0,-cameraPos.x),
////        simd_make_float4(0,1,0,-cameraPos.y),
////        simd_make_float4(0,0,1,-cameraPos.z),
////        simd_make_float4(0,0,0,1),
////    };
////
////    simd_float4x4 viewMatrix = {
////        simd_make_float4(sqrt(0.5),0,sqrt(0.5),0),
////        simd_make_float4(sqrt(0.25),sqrt(0.5),-sqrt(0.25),0),
////        simd_make_float4(-sqrt(0.25),sqrt(0.5),sqrt(0.25),0),
////        simd_make_float4(0,0,0,1),
////    };
//
//    simd_float3 cameraPos = simd_make_float3(0.5 * canvasWidth * 0.5, 0.5 * canvasHeight, 0.5 * canvasWidth * 0.5);
//    simd_float4x4 posMatrix = {
//        simd_make_float4(1,0,0,-cameraPos.x),
//        simd_make_float4(0,1,0,-cameraPos.y),
//        simd_make_float4(0,0,1,-cameraPos.z),
//        simd_make_float4(0,0,0,1),
//    };
//
//    simd_float4x4 viewMatrix = {
//        simd_make_float4(sqrt(0.5),0,sqrt(0.5),0),
//        simd_make_float4(0,1,0,0),
//        simd_make_float4(-sqrt(0.5),0,sqrt(0.5),0),
//        simd_make_float4(0,0,0,1),
//    };
//
//    return simd_mul(posMatrix,viewMatrix);
//}
//
//
//static simd_float4x4 getProjectionMatrix2(size_t canvasWidth, size_t canvasHeight) {
//    const CGFloat n = 1;
//    const CGFloat f = 100.0;
//    const CGFloat r = canvasWidth / 2.0;
//    const CGFloat t = canvasHeight / 2.0;
//    simd_float4x4 projectionMatrix = {
//        simd_make_float4(1/r, 0, 0, 0),
//        simd_make_float4(0, 1/t, 0, 0),
//        simd_make_float4(0, 0, -2/(f-n), -(f+n)/(f-n)),
//        simd_make_float4(0, 0, 0, 1),
//    };
//    return projectionMatrix;
//}
//
//
//@interface PXCShadowTestVC () {
//    GLuint _framebuffer;
//    CXXPixelBufferPoolAdaptor *_pixelPool;
//    CVOpenGLESTextureCacheRef _coreTextureCache;
//}
//@property (nonatomic) PXCCameraDisplayView *dispalyer;
//@end
//
//@implementation PXCShadowTestVC
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    [[CXXContext sharedInstance] runSyncOnRenderingQueue:^{
//        [GPUImageContext useImageProcessingContext];
//        GLuint framebuffer;
//        glGenFramebuffers(1, &framebuffer);
//        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//        self->_framebuffer = framebuffer;
//        self->_pixelPool = [CXXPixelBufferPoolAdaptor adaptor];
//        self->_coreTextureCache = [GPUImageContext sharedImageProcessingContext].coreVideoTextureCache;
//
//        [self->_pixelPool enter];
//    }];
//
//
//    PXCCameraDisplayView *view = [[PXCCameraDisplayView alloc] initWithFrame:CGRectMake(0, 64, 375, 375)];
//    [self.view addSubview:view];
//    self.dispalyer = view;
//
//
//
//
//    UIImage *image = [UIImage imageNamed:@"ipad_1"];
//
//    CXXGLESTexture *texture = GLESTextureFromImage(image);
//    CXXGLESTexture *texture2 = GLESTextureFromImage(image);
//
//
//    [[CXXContext sharedInstance] runSyncOnRenderingQueue:^{
//
//        GPUImageContext *glContext = [GPUImageContext sharedImageProcessingContext];
//        [glContext useAsCurrentContext];
//        glBindFramebuffer(GL_FRAMEBUFFER, self->_framebuffer);
//        glViewport(0, 0, (GLsizei)CVPixelBufferGetWidth(texture2.pixel), (GLsizei)CVPixelBufferGetHeight(texture2.pixel));
//        glFramebufferTexture2D(GL_FRAMEBUFFER,
//                               GL_COLOR_ATTACHMENT0,
//                               CVOpenGLESTextureGetTarget(texture2.texture),
//                               CVOpenGLESTextureGetName(texture2.texture),
//                               0);
//
//        glClearColor(1., 0, 0, 1.0);
//        glClear(GL_COLOR_BUFFER_BIT);
//
//
//        GLProgram *glProgram = [self glProgram];
//        [glContext setContextShaderProgram:glProgram];
//
//        simd_float4x4 positionMatix = {
//            simd_make_float4(-25, -25, 0, 1),
//            simd_make_float4( 25, -25, 0, 1),
//            simd_make_float4(-25,  25, 0, 1),
//            simd_make_float4( 25,  25, 0, 1),
//        };
////        simd_float4x4 positionMatix = {
////            simd_make_float4(-50, -50, 0, 1),
////            simd_make_float4( 50, -50, 0, 1),
////            simd_make_float4(-50,  50, 0, 1),
////            simd_make_float4( 50,  50, 0, 1),
////        };
//
//
//        GLuint attributePositionIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_POSITION];
//        glVertexAttribPointer(attributePositionIndex, 4, GL_FLOAT, 0, 0, (GLfloat *)&positionMatix);
//        glEnableVertexAttribArray(attributePositionIndex);
//
//        GLfloat locations[] = {0 ,0 ,1 , 0 , 0 , 1 , 1 , 1,};
//
//        GLuint attributeTexCoordIndex = [glProgram attributeIndex:CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE];
//        glVertexAttribPointer(attributeTexCoordIndex, 2, GL_FLOAT, 0, 0, (GLfloat *)locations);
//        glEnableVertexAttribArray(attributeTexCoordIndex);
//
//        simd_float4x4 modelMatix = {
//            simd_make_float4(1, 0, 0, 50),
//            simd_make_float4(0, 1, 0, 50),
//            simd_make_float4(0, 0, 1, 0),
//            simd_make_float4(0, 0, 0, 1),
//        };
//
//        simd_float4x4 modelMatix2 = simd_transpose(modelMatix);
//
//        GLuint model = [glProgram uniformIndex:@"model"];
//        glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatix2);
//
//        simd_float4x4 viewMatix = simd_transpose(getViewMatrix2(100, 100));
//        GLuint view = [glProgram uniformIndex:@"view"];
//        glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatix);
//
//
//        simd_float4x4 projectionMatix = simd_transpose(getProjectionMatrix2(100 * sqrt(0.5), 100));
//        GLuint projection = [glProgram uniformIndex:@"projection"];
//        glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatix);
//
//
//
//        glUniform1i([glProgram uniformIndex:CXX_GLSL_UNIFORM_INPUT_TEXTURE], 0);
//        glActiveTexture(GL_TEXTURE0);
//
//        glBindTexture(CVOpenGLESTextureGetTarget(texture.texture), CVOpenGLESTextureGetName(texture.texture));
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//
//
//
//        glFinish();
//    }];
//
//
//    [self.dispalyer pixelBufferReady:texture2.pixel];
//
//
//
//
//
//}
//
//
//
//
//
//
//
//
//
//
//- (IBAction)onBack:(id)sender {
//    [[CXXContext sharedInstance] runSyncOnRenderingQueue:^{
//        GLuint framebuffer = self->_framebuffer;
//        glDeleteFramebuffers(1, &framebuffer);
//        [self->_pixelPool leave];
//        self->_framebuffer = 0;
//        self->_pixelPool = nil;
//        self->_coreTextureCache = nil;
//    }];
//
//    [self.navigationController popViewControllerAnimated:NO];
//}
//
//
//#pragma mark -
//- (GLProgram *)glProgram {
//    static GLProgram *glProgram;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
////        CXXGLESShaderStringCache *cache = [CXXGLESShaderStringCache sharedInstance];
////        NSString *vertString = [cache shaderWithNamed:@"Passthrough3D.vsh" andBundleName:CXX_COMPOSITOR_BUNDLE];
////        NSString *fragString = [cache shaderWithNamed:@"BlendINP.fsh" andBundleName:CXX_COMPOSITOR_BUNDLE];
////        NSString *blendString = [cache shaderWithNamed:@"normal.fsh" andBundleName:CXX_BLEND_FUNCTIONS_BUNDLE];
////        fragString = [fragString stringByReplacingOccurrencesOfString:@"@fun(blend)" withString:blendString];
//        NSArray<NSString *> *attributeNames = @[
//            CXX_GLSL_ATTRIBUTES_POSITION,
//            CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE,
//        ];
//        glProgram = CXXLoadGLProgram(shadowVs, shadowFs, attributeNames);
//    });
//    return glProgram;
//}
//@end
