//
//  THBFilterManager.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <Foundation/Foundation.h>

#import "THBFilterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBFilterManager : NSObject
+ (instancetype)manager;

@property (nonatomic) NSArray<THBFilterModel *> *modelArrays;
@end

NS_ASSUME_NONNULL_END
