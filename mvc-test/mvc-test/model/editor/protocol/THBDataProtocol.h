//
//  THBRenderProtocol.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <Foundation/Foundation.h>

#import "THBEditModel.h"
#import "THBData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol THBDataProtocol <NSObject>
@property (nonatomic) THBData *data;

@end

NS_ASSUME_NONNULL_END
