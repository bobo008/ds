//
//  THBFilterController.m
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import "THBFilterController.h"

#import "THBFilterView.h"

@implementation THBFilterController




- (void)setup {
    THBFilterView *view = [[THBFilterView alloc] initWithFrame:self.frame];
    view.selectItem = ^(THBFilterModel *model) {
        //TODO:选择了一个滤镜，修改底层数据
        self.editor.data.filterID = model.filterID;
    };
    [self.superView addSubview:view];
}
@end
