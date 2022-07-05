
#import "THBFilterMVVMViewModel.h"


#import "THBFilterManager.h"


@interface THBFilterMVVMViewModel ()



@property (nonatomic) id<THBDataProtocol, THBEditModelProtocol> editor;

@end


@implementation THBFilterMVVMViewModel


@synthesize seletIndex = _seletIndex;

- (instancetype)initWithEditor:(id<THBDataProtocol, THBEditModelProtocol>)editor  {
    self = [super init];
    if (self) {
        self.editor = editor;
        self.seletIndex = -1;
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
    self.editor.data.filterID = dict[@"label"];
    
    NSArray *array = [THBFilterManager manager].modelArrays;
    for (int i = 0; i < array.count; i++) {
        THBFilterModel *model = array[i];
        if ([model.filterID isEqualToString:self.editor.data.filterID]) {
            self.seletIndex = i;
            break;
        }
    }
    
}


- (void)enterFilterEdit {
    self.editor.editModel.currentEditItem = @"Filter";
    [self.editor.editModel.array addObject:@"Filter"];
}

- (void)quitFilterEdit {
    [self.editor.editModel.array removeLastObject];
    self.editor.editModel.currentEditItem = self.editor.editModel.array.lastObject;
}


@end
