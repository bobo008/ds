//
//  THBTestBtn.m
//  opengl-test
//
//  Created by tanghongbo on 2022/7/6.
//

#import "THBTestBtn.h"

@implementation THBTestBtn

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - btn touch begin");
    [super touchesBegan:touches withEvent:event];
    NSLog(@"test - btn touch begin2");
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - btn touch end");
    [super touchesEnded:touches withEvent:event];
    NSLog(@"test - btn touch end2");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - btn touch move");
    [super touchesMoved:touches withEvent:event];
    NSLog(@"test - btn touch move2");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"test - btn touch cancel");
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"test - btn touch cancel2");
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL ret = [super gestureRecognizerShouldBegin:gestureRecognizer];
    return ret;
}

@end
