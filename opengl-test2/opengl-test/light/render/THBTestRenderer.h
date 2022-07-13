
#import <Foundation/Foundation.h>



#import "THBContext.h"


NS_ASSUME_NONNULL_BEGIN



@interface THBTestRenderer : NSObject

@property (nonatomic, readonly) THBPixelBufferPoolAdaptor *pixelPool;


- (void)setup;

- (void)dispose;

- (THBGLESTexture *)drawCanvas;


@end




NS_ASSUME_NONNULL_END
