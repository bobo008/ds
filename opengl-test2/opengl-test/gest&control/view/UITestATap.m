//
//  UITestTap.m
//  opengl-test
//
//  Created by tanghongbo on 2022/7/6.
//

#import "UITestATap.h"

@implementation UITestATap


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap a touch begin");
    [super touchesBegan:touches withEvent:event];
    NSLog(@"test - tap a touch begin2");
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap a touch end");
    [super touchesEnded:touches withEvent:event];
    NSLog(@"test - tap a touch end2");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap a touch move");
    [super touchesMoved:touches withEvent:event];
    NSLog(@"test - tap a touch move2");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - tap a touch cancel");
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"test - tap a touch cancel2");
}



@end
