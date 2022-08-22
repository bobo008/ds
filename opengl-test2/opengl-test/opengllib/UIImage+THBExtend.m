
#import "UIImage+THBExtend.h"

@implementation UIImage (THBExtend)


- (UIImage *)cxx_flipImage {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -self.size.height);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
