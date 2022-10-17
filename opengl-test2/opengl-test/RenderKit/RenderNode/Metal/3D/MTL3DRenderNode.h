//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

#import "PPPMTLRenderDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTL3DRenderNode : NSObject
+ (instancetype)renderNode;

@property (nonatomic) PPPMTLTexture *outputTexture;
@property (nonatomic) PPPMTLTexture *inputTexture;



@property (nonatomic) matrix_float4x4 mvpMatrix;

@property (nonatomic) matrix_float4x4 pos;

@property (nonatomic) matrix_float4x2 tex;
    
    

- (void)render;

@end



NS_ASSUME_NONNULL_END
