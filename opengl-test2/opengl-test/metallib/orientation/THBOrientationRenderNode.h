//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBOrientationRenderNode : NSObject

+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation;

+ (CVPixelBufferRef)correct:(CVPixelBufferRef)pixel inverseOrientation:(UIImageOrientation)orientation;

+ (CVPixelBufferRef)correctUseMetal:(CVPixelBufferRef)pixel orientation:(UIImageOrientation)orientation;

@end



NS_ASSUME_NONNULL_END
