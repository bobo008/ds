
#import <Foundation/Foundation.h>



#import "THBContext.h"


NS_ASSUME_NONNULL_BEGIN



@interface THBShadowTestRenderer : NSObject

@property (nonatomic, readonly) THBPixelBufferPoolAdaptor *pixelPool;


- (void)setup;

- (void)dispose;

- (THBGLESTexture *)drawCanvas;


- (THBGLESTexture *)drawShadowMap;




@property (nonatomic) float scale;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;


@property (nonatomic) float light;



@property (nonatomic) float offset_x;
@property (nonatomic) float offset_y;
@property (nonatomic) float offset_z;


@end




NS_ASSUME_NONNULL_END
