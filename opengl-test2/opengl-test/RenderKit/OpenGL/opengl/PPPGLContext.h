//
//  CXXContext.h
//  PXCEditor
//
//  Created by huangguanzhe on 2021/7/10.
//

#import <Foundation/Foundation.h>


#import "PPPGLTextureUtil.h"
#import "PPPGLTexture.h"



#import "GLProgram.h"
#import "GPUImageContext.h"
#import <simd/simd.h>

#define CXX_GLSL_ATTRIBUTES_POSITION                @"position"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE      @"inputTextureCoordinate"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE2     @"inputTextureCooridnate2"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE3     @"inputTextureCooridnate3"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE4     @"inputTextureCooridnate4"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE5     @"inputTextureCooridnate5"
#define CXX_GLSL_ATTRIBUTES_TEXTURE_COORDINATE6     @"inputTextureCooridnate6"

#define CXX_GLSL_UNIFORM_INPUT_TEXTURE              @"inputImageTexture"
#define CXX_GLSL_UNIFORM_INPUT_TEXTURE2             @"inputImageTexture2"
#define CXX_GLSL_UNIFORM_INPUT_TEXTURE3             @"inputImageTexture3"
#define CXX_GLSL_UNIFORM_INPUT_TEXTURE4             @"inputImageTexture4"
#define CXX_GLSL_UNIFORM_INPUT_TEXTURE5             @"inputImageTexture5"
#define CXX_GLSL_UNIFORM_INPUT_TEXTURE6             @"inputImageTexture6"


@interface PPPGLContext : NSObject
@property(readonly, retain, nonatomic) EAGLContext *context;

+ (instancetype)sharedInstance;

+ (void)useImageProcessingContext;


- (void)runSyncOnRenderingQueue:(void (^)(void))block;
- (void)runAsyncOnRenderingQueue:(void (^)(void))block;




GLProgram * GLLoadGLProgram(NSString *vertexString, NSString *fragmentString, NSArray<NSString *> *attributeNames);

@end


