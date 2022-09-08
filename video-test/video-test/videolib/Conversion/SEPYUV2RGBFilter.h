//
//  SEPYUV2RGBFilter.h
//  preresearch
//
//  Created by lllllll on 2022/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SEPYUV2RGBFilter : NSObject
@property (nonatomic) CVPixelBufferRef YUVPixels;
@property (nonatomic) CVPixelBufferRef RGBPixels;
@property (nonatomic) CVOpenGLESTextureRef RGBTexture;

- (void)render;
@end

NS_ASSUME_NONNULL_END
