

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBPixelBufferPoolAdaptor : NSObject
+ (instancetype)adaptor;
- (void)enter;
- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size;
- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size formatType:(OSType)formatType;
- (CVPixelBufferRef)pixelBufferWithWidth:(size_t)width height:(size_t)height;
- (void)leave;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
