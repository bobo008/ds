//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

#import "PPPMTLRenderDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTL3DRenderer : NSObject
+ (instancetype)renderNode;

@property (nonatomic) PPPMTLTexture *outputTexture;
@property (nonatomic) PPPMTLTexture *inputTexture;


@property (nonatomic) id<MTLBuffer> vaoBuffer;
@property (nonatomic) id<MTLBuffer> vboBuffer;
@property (nonatomic) int count;
@property (nonatomic) matrix_float4x4 mvpMatrix;

- (void)render;

@end

// 这个测试render 请先不要删除！！

NS_ASSUME_NONNULL_END
