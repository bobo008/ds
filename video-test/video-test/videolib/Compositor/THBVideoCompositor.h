
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "THBVideoRenderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBVideoCompositor : NSObject <AVVideoCompositing>

+ (void)setVideoRender:(nullable id<THBVideoRenderProtocol>)render;

+ (Class<AVVideoCompositing>)subClassWithUniqStr:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
