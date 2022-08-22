

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant T> (THBBasicExtend)

+ (NSArray<id> *)THB_zip:(NSArray<NSArray *> *)arrays;

- (NSArray<T> *)THB_arrayByDeleteObjectWhere:(BOOL(^)(T obj, NSUInteger idx, BOOL *stop))block;

- (T)THB_findObjectWhere:(BOOL(^)(T obj, NSUInteger idx))block;

- (NSArray<T> *)THB_removeObjectAtIndex:(NSUInteger)index;

- (NSArray<T> *)THB_removeLastObject;

- (NSArray<T> *)THB_arrayByInsertObject:(T)object atIndex:(NSUInteger)index;

- (NSArray<T> *)THB_arrayByInsertObjectArray:(NSArray<T> *)objectArray atIndex:(NSUInteger)index;

- (NSArray<id> *)THB_arrayMap:(id(^)(T obj, NSUInteger idx, BOOL *stop))block;

- (NSArray<id> *)THB_arrayMapPermitNil:(id _Nullable (^)(T _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop))block;

- (NSArray<T> *)THB_arrayFilter:(BOOL(^)(T obj, NSUInteger idx, BOOL *stop))block;

- (NSArray<id> *)THB_flatten;

- (NSArray<NSArray<T> *> *)THB_group:(int32_t)batch;

@end




NS_ASSUME_NONNULL_END
