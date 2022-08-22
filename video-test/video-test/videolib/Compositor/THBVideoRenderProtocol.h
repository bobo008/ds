//  Created on 2021/8/2.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol THBVideoRenderProtocol <NSObject>

- (CVPixelBufferRef)renderWithRequest:(AVAsynchronousVideoCompositionRequest *)request;

@end

NS_ASSUME_NONNULL_END
