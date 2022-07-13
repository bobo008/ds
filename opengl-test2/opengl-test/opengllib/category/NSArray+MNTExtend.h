//
//  NSArray+MNTExtend.h
//  MotionNinja
//
// on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (MNTExtend)


- (NSArray<ObjectType> *)eav_arrayFilter:(BOOL(^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
