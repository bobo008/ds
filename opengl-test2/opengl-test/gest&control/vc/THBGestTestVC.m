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


@interface THBGestTestVC ()

@end

@implementation THBGestTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
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
    [bView addGestureRecognizer:tap2];
    
//    UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
//    UICollectionView *scrollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) collectionViewLayout:layout];
//    scrollView.backgroundColor = UIColor.grayColor;
//    [bView addSubview:scrollView];
    
    
    THBTestBtn *btn = [[THBTestBtn alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [bView addSubview:btn];
    [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];

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



- (void)onTap {
    NSLog(@"tap");
}



@end
