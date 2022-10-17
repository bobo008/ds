//
//  MNTPPixelBufferPool.h
//  MotionNinja
//
// on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPPPixelBufferPool : NSObject
- (CVPixelBufferRef)fetch:(CGSize)size; 
- (void)purge:(NSSet<NSString *> *)usingSizeSet;
@end

NS_ASSUME_NONNULL_END
