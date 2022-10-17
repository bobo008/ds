

#import <UIKit/UIKit.h>

#import "PPPMTLTexture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPPMTLTextureUtil : NSObject
+ (PPPMTLTexture *)createBySize:(CGSize)size;
+ (PPPMTLTexture *)createBySize:(CGSize)size format:(const OSType)format;



+ (PPPMTLTexture *)createWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;




+ (PPPMTLTexture *)createWithImage:(UIImage *)image;
@end




NS_ASSUME_NONNULL_END
