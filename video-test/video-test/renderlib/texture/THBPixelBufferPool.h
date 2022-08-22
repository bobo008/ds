

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBPixelBufferPool : NSObject

+ (instancetype)pool;

+ (NSString *)keyWithSize:(CGSize)size formatType:(OSType)formatType;

- (CVPixelBufferRef)pixelBufferWithSize:(CGSize)size formatType:(OSType)formatType;
- (void)flush:(NSSet<NSString *> *)usingKeySet;
- (void)flushAll;

- (CVPixelBufferRef)STDPixelBufferWithSize:(CGSize)size;
- (void)STDFlush:(NSSet<NSValue *> *)usingSizeSet;
@end

NS_ASSUME_NONNULL_END
