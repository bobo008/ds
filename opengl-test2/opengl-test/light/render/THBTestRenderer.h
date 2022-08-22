
#import <Foundation/Foundation.h>



#import "THBContext.h"


NS_ASSUME_NONNULL_BEGIN



@interface THBTestRenderer : NSObject

@property (nonatomic, readonly) THBPixelBufferPoolAdaptor *pixelPool;


- (void)setup;

- (void)dispose;

- (THBTexture *)drawCanvas;



@property (nonatomic) float scale;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

@end




NS_ASSUME_NONNULL_END
