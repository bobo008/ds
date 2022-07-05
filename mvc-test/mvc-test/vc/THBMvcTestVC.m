//
//  THBMvcTestVC.m
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import "THBMvcTestVC.h"

#import "THBEditor.h"

#import "THBFilterView.h"

#import "THBFilterController.h"

#import "THBFilterMVPController.h"

#import "THBFilterMVVMController.h"

#import "THBFilterManager.h"

#define TOP_MARGIN     (((UINavigationController *)(UIApplication.sharedApplication.delegate.window.rootViewController)).view.safeAreaInsets.top)
#define BOTTOM_MARGIN  (((UINavigationController *)(UIApplication.sharedApplication.delegate.window.rootViewController)).view.safeAreaInsets.bottom)
#define SCREEN_WIDTH        (UIScreen.mainScreen.bounds.size.width)
#define SCREEN_HEIGHT       (UIScreen.mainScreen.bounds.size.height)


@interface THBMvcTestVC ()
@property (nonatomic) THBEditor *editor;
@end

@implementation THBMvcTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupEditor];
    [self setupFilterView4];
}

- (void)dealloc {
    [self.editor uninstall];
}

- (void)setupEditor {
    THBEditModel *editModel = [[THBEditModel alloc] init];
    THBData *data = [[THBData alloc] init];
    self.editor = [[THBEditor alloc] init];
    [self.editor install:data editModel:editModel];
    
}

/// mvc - mode 1
- (void)setupFilterView1 {
    THBFilterView *view = [[THBFilterView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BOTTOM_MARGIN - 100, SCREEN_WIDTH, 100)];
    view.selectItem = ^(THBFilterModel *model) {
        //TODO:选择了一个滤镜，修改底层数据
        self.editor.data.filterID = model.filterID;

    };
    [self.view addSubview:view];
}





/// mvc - mode 2
- (void)setupFilterView2 {
    THBFilterController *controller = [[THBFilterController alloc] init];
    controller.frame = CGRectMake(0, SCREEN_HEIGHT - BOTTOM_MARGIN - 100, SCREEN_WIDTH, 100);
    controller.superView = self.view;
    controller.editor = self.editor;
    [controller setup];    
}



/// mvp - mode 1
- (void)setupFilterView3 {
    THBFilterMVPController *controller = [[THBFilterMVPController alloc] init];
    controller.frame = CGRectMake(0, SCREEN_HEIGHT - BOTTOM_MARGIN - 100, SCREEN_WIDTH, 100);
    controller.superView = self.view;
    controller.editor = self.editor;
    [controller setup];
}


/// mvvm - mode 1
- (void)setupFilterView4 {
    THBFilterMVVMController *controller = [[THBFilterMVVMController alloc] init];
    controller.frame = CGRectMake(0, SCREEN_HEIGHT - BOTTOM_MARGIN - 100, SCREEN_WIDTH, 100);
    controller.superView = self.view;
    controller.editor = self.editor;
    [controller install];
}





@end
