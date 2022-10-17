//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

#import "PPPMTLRenderDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTLMergeRenderNode : NSObject
+ (instancetype)renderNode;

@property (nonatomic) PPPMTLTexture *outputTexture;
@property (nonatomic) PPPMTLTexture *inputTexture;
@property (nonatomic) PPPMTLTexture *mlResTexture;
@property (nonatomic) PPPMTLTexture *maskTexture;
@property (nonatomic) CGRect roiRect;


- (void)render;


- (void)finish;
@end



NS_ASSUME_NONNULL_END
