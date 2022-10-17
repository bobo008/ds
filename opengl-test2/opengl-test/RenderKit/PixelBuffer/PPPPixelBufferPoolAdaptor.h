//
//  MNTPPixelBufferPoolAdaptor.h
//  MotionNinja
//
// on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPPPixelBufferPoolAdaptor : NSObject
+ (instancetype)instance;
- (void)enter;
- (CVPixelBufferRef)fetch:(CGSize)size;
- (void)leave;
@end

NS_ASSUME_NONNULL_END
