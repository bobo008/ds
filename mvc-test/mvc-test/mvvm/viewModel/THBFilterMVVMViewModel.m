
#import "THBFilterMVVMViewModel.h"


#import "THBFilterManager.h"


@interface THBFilterMVVMViewModel ()




@end


@implementation THBFilterMVVMViewModel


@synthesize seletIndex = _seletIndex;

- (instancetype)init {
    self = [super init];
    if (self) {

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

- (void)selectItem:(NSDictionary *)dict index:(int)index {
    //TODO: 修改底层数据 通知view去改选中框
    
    self.seletIndex = 1;
}



@end
