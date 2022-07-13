//
//  NSArray+MNTExtend.m
//  MotionNinja
//
// on 2020/11/26.
//

#import "NSArray+MNTExtend.h"

@implementation NSArray (MNTExtend)

- (NSArray *)eav_arrayFilter:(BOOL (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL reserve = block(obj, idx, stop);
        if (reserve) {
            [mutableArray addObject:obj];
        }
    }];
    return [mutableArray copy];
}
@end
