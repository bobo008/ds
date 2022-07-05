//
//  THBFilterManager.m
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import "THBFilterManager.h"

@implementation THBFilterManager

+ (instancetype)manager {
    static THBFilterManager *manager;
    static dispatch_once_t managerOnceToken;
    dispatch_once(&managerOnceToken, ^{
        manager = [[THBFilterManager alloc] init];
    });
    return manager;
}


- (instancetype)init {
    self = [super init];
    if (self) {

        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            THBFilterModel *model = [[THBFilterModel alloc] init];
            model.filterID = [NSString stringWithFormat:@"Filter %@",@(i)];
            [array addObject:model];
            
        }
        
        self.modelArrays = array.mutableCopy;
    }
    return self;
}

@end
