

#import <UIKit/UIKit.h>

#import "PPPGLTexture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPPGLTextureUtil : NSObject
+ (PPPGLTexture *)createBySize:(CGSize)size;
+ (PPPGLTexture *)createBySize:(CGSize)size format:(const OSType)format;
@end




NS_ASSUME_NONNULL_END
