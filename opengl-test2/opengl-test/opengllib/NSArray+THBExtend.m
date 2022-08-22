

#import "NSArray+THBExtend.h"


@implementation NSArray (THBBasicExtend)

+ (NSArray<id> *)THB_zip:(NSArray<NSArray *> *)arrays {
    if (arrays.count == 0) {
        return @[];
    }
    NSUInteger minCount = arrays[0].count;
    for (int i = 1; i < arrays.count; i++) {
        if (minCount > arrays[i].count) {
            minCount = arrays[i].count;
        }
    }
    
    NSMutableArray *retArray;
    for (int i = 0; i < minCount; i++) {
        NSMutableArray *retArrayEle = [NSMutableArray array];
        for (int j = 0; j < arrays.count; j++) {
            [retArrayEle addObject:arrays[j][i]];
        }
        [retArray addObject:retArrayEle];
    }
    return retArray;
}

- (NSArray *)THB_arrayByDeleteObjectWhere:(BOOL (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    NSMutableArray *mutableSelf = [self mutableCopy];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [mutableSelf enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL needDelete = block(obj, idx, stop);
        if (needDelete) {
            [indexSet addIndex:idx];
        }
    }];
    if ([indexSet count] > 0) {
        [mutableSelf removeObjectsAtIndexes:indexSet];
    }
    return [mutableSelf copy];
}

- (id)THB_findObjectWhere:(BOOL (^)(id _Nonnull, NSUInteger))block {
    __block id target = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL found = block(obj, idx);
        if (found) {
            target = obj;
            *stop = YES;
        }
    }];
    return target;
}

- (NSArray *)THB_removeObjectAtIndex:(NSUInteger)index {
    NSMutableArray *mutableSelf = [self mutableCopy];
    [mutableSelf removeObjectAtIndex:index];
    return [mutableSelf copy];
}

- (NSArray *)THB_removeLastObject {
    if (self.count == 0) {
        return @[];
    }
    return [self THB_removeObjectAtIndex:self.count-1];
}

- (NSArray *)THB_arrayByInsertObject:(id)object atIndex:(NSUInteger)index {
    NSMutableArray *mutableSelf = [self mutableCopy];
    NSAssert(index <= [mutableSelf count], @"index越界");
    if (index == [mutableSelf count]) {
        [mutableSelf addObject:object];
    } else {
        [mutableSelf insertObject:object atIndex:index];
    }
    return [mutableSelf copy];
}

- (NSArray *)THB_arrayByInsertObjectArray:(NSArray *)objectArray atIndex:(NSUInteger)index {
    NSUInteger count = [self count];
    NSAssert(index <= count, @"index越界");
    if (index == 0) {
        return [objectArray arrayByAddingObjectsFromArray:self];
    } else if (index == count) {
        return [self arrayByAddingObjectsFromArray:objectArray];
    } else {
        NSArray *a1 = [self subarrayWithRange:NSMakeRange(0, index)];
        NSArray *a2 = [self subarrayWithRange:NSMakeRange(index, count - index)];
        return [[a1 arrayByAddingObjectsFromArray:objectArray] arrayByAddingObjectsFromArray:a2];
    }
}

- (NSArray<id> *)THB_arrayMap:(id  _Nonnull (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id ele = block(obj, idx, stop);
        [mutableArray addObject:ele];
    }];
    return [mutableArray copy];
}

- (NSArray<id> *)THB_arrayMapPermitNil:(id  _Nullable (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id ele = block(obj, idx, stop);
        if (ele) {
            [mutableArray addObject:ele];
        }
    }];
    return [mutableArray copy];
}

- (NSArray *)THB_arrayFilter:(BOOL (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL reserve = block(obj, idx, stop);
        if (reserve) {
            [mutableArray addObject:obj];
        }
    }];
    return [mutableArray copy];
}

- (NSArray<id> *)THB_flatten {
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [mutableArray addObjectsFromArray:[(NSArray *)obj THB_flatten]];
        } else {
            [mutableArray addObject:obj];
        }
    }];
    return [mutableArray copy];
}

- (NSArray *)THB_group:(int32_t)batch {
    NSMutableArray<NSArray *> *retArray = [NSMutableArray array];
    NSMutableArray *segment = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != 0 && idx % batch == 0) {
            [retArray addObject:[segment copy]];
            [segment removeAllObjects];
        }
        [segment addObject:obj];
    }];
    [retArray addObject:[segment copy]];
    [segment removeAllObjects];
    return [retArray copy];
}

@end

