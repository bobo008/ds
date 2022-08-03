//  Created on 2022/3/9.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBMSAARenderNode : NSObject

@property (nonatomic) CVPixelBufferRef input;
- (CVPixelBufferRef)render;
@end



NS_ASSUME_NONNULL_END
