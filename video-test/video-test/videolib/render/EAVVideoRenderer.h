

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#import "THBVideoRenderProtocol.h"

#import "THBPixelBufferPoolAdaptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAVVideoRenderer : NSObject <THBVideoRenderProtocol>
//@property (nonatomic) AVAsynchronousVideoCompositionRequest *request;
//@property (nonatomic) AVVideoCompositionRenderContext *renderContext;

@property (nonatomic, readonly) GLuint framebufferHandle;
@property (nonatomic, readonly) THBPixelBufferPoolAdaptor *pixelPool;


@property (nonatomic) NSDictionary<NSString *, id> *renderComposeTrackIdMap;


- (instancetype)init;

- (void)beforeRender;
- (nullable CVPixelBufferRef)render;
- (void)afterRender;





@end

NS_ASSUME_NONNULL_END
