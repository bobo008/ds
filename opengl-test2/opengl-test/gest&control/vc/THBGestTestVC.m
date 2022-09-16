//
//  THBOpenglTestVC.m
//  opengl-test
//
//  Created by tanghongbo on 2022/7/6.
//

#import "THBGestTestVC.h"

#import "THBTestAView.h"
#import "THBTestBView.h"
#import "THBTestCView.h"
#import "UITestTap.h"
#import "UITestATap.h"
#import "THBTestBtn.h"


@interface THBGestTestVC ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation THBGestTestVC


- (void)viewDidLoad {
    [super viewDidLoad];
    //create a red layer
    [self setup];
    
 
}


- (void)setup2 {
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(0, 0, 100, 100);
    self.colorLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:self.colorLayer];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //get the touch point
    //check if we've tapped the moving layer
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if ([self.colorLayer.presentationLayer hitTest:point]) {
        //randomize the layer background color
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
    } else {
        //otherwise (slowly) move the layer to new position
        [CATransaction begin];
        [CATransaction setAnimationDuration:4.0];
        self.colorLayer.position = point;
        [CATransaction commit];
    }
}
    



- (void)setup {
    THBTestAView *aView = [[THBTestAView alloc] initWithFrame:CGRectMake(0, 200, 375, 375)];
    aView.backgroundColor = UIColor.redColor;
    [self.view addSubview:aView];
    
    THBTestBView *bView = [[THBTestBView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    bView.backgroundColor = UIColor.yellowColor;
    [aView addSubview:bView];
    
    
    UITestATap *tap = [[UITestATap alloc] initWithTarget:self action:@selector(onTap)];
    [aView addGestureRecognizer:tap];
    
    UITestTap *tap2 = [[UITestTap alloc] initWithTarget:self action:@selector(onTap2)];
    tap2.edges = UIRectEdgeLeft;
//    tap2.delegate = self;
    [bView addGestureRecognizer:tap2];

    

    
    
//    UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
//    UICollectionView *scrollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) collectionViewLayout:layout];
//    scrollView.backgroundColor = UIColor.grayColor;
//    [bView addSubview:scrollView];
    

//    THBTestBtn *btn = [[THBTestBtn alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//    [bView addSubview:btn];
//    [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
//

//    THBTestCView *cView = [[THBTestCView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    cView.backgroundColor = UIColor.blueColor;
//    [btn addSubview:cView];
}


- (void)action {
    NSLog(@"action");
}

- (void)onTap2 {
    NSLog(@"tap2");
}


- (void)onTap4 {
    NSLog(@"tap4");
}

- (void)onTap5 {
    NSLog(@"tap5");
}

- (void)onTap {
    NSLog(@"tap");
}




- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UITestTap.class] && [otherGestureRecognizer isKindOfClass:UITestATap.class]) {
        return YES;
    }
    return NO;
}




@end



