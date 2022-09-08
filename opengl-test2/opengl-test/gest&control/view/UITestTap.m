//
//  UITestTap.m
//  opengl-test
//
//  Created by tanghongbo on 2022/7/6.
//

#import "UITestTap.h"

@implementation UITestTap


//+(void)load {
//    NSLog(@"bbbbb  load");
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap b touch begin");
    [super touchesBegan:touches withEvent:event];
    NSLog(@"test - tap b touch begin2");
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap b touch end");
    [super touchesEnded:touches withEvent:event];
    NSLog(@"test - tap b touch end2");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap b touch move");
    [super touchesMoved:touches withEvent:event];
    NSLog(@"test - tap b touch move2");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap b touch cancel");
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"test - tap b touch cancel2");
}



@end
