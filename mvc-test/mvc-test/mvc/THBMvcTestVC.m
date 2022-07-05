//
//  THBMvcTestVC.m
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import "THBMvcTestVC.h"


#import "THBFilterView.h"



#define TOP_MARGIN     (((UINavigationController *)(UIApplication.sharedApplication.delegate.window.rootViewController)).topLayoutGuide.length)
#define BOTTOM_MARGIN  (((UINavigationController *)(UIApplication.sharedApplication.delegate.window.rootViewController)).bottomLayoutGuide.length)
#define SCREEN_WIDTH        (UIScreen.mainScreen.bounds.size.width)
#define SCREEN_HEIGHT       (UIScreen.mainScreen.bounds.size.height)


@interface THBMvcTestVC ()

@end

@implementation THBMvcTestVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupFilterView];
}


- (void)setupFilterView {
    THBFilterView *view = [[THBFilterView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BOTTOM_MARGIN - 100, SCREEN_WIDTH, 100)];
    [self.view addSubview:view];
}


@end
