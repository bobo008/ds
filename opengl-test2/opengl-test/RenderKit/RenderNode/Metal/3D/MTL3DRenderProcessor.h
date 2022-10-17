//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

#import "PPPMTLRenderDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTL3DRenderProcessor : NSObject
//+ (instancetype)renderNode;
+ (instancetype)renderNode:(CGSize)size;

@property (nonatomic) PPPMTLTexture *outputTexture;
@property (nonatomic) PPPMTLTexture *inputTexture;
- (void)start; // setp 之前请 设置这两个纹理


// 每次render 都重置一下这四个数据
@property (nonatomic) id<MTLBuffer> vaoBuffer;
@property (nonatomic) id<MTLBuffer> vboBuffer;
@property (nonatomic) int count;
@property (nonatomic) matrix_float4x4 mvpMatrix;

- (void)render;


- (void)end;


@end



NS_ASSUME_NONNULL_END
