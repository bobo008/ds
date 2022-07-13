
#import "THBFilterMVPPersenter.h"


#import "THBFilterManager.h"


@interface THBFilterMVPPersenter ()


@property (nonatomic) THBEditor *editor;

@end


@implementation THBFilterMVPPersenter




- (instancetype)initWithEditor:(THBEditor *)editor {
    self = [super init];
    if (self) {
        self.editor = editor;
    }
    return self;
}


- (NSArray *)obtainArray {
    NSArray *array = [THBFilterManager manager].modelArrays;

    NSMutableArray *ret = [NSMutableArray array];
    for (THBFilterModel *model in array) {
        NSDictionary *dic = @{@"label":model.filterID};
        [ret addObject:dic];
    }
    return ret.copy;
}

- (void)selectItem:(NSDictionary *)dict {
    //TODO: 修改底层数据 通知view去改选中框
//    if down
    self.editor.data.filterID = dict[@"label"];
    
    int index;
    NSArray *array = [THBFilterManager manager].modelArrays;
    for (int i = 0; i < array.count; i++) {
        THBFilterModel *model = array[i];
        if ([model.filterID isEqualToString:self.editor.data.filterID]) {
            index = i;
            break;
        }
    }

    
    NSDictionary *info = @{@"selectItem": @(index),};
    [[NSNotificationCenter defaultCenter] postNotificationName:THBFilterMVPUpdateNotificaiton object:self userInfo:info];
}

@end
