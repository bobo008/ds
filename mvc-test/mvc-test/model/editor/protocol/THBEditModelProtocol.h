//
//  THBRenderProtocol.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <Foundation/Foundation.h>

#import "THBEditModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol THBEditModelProtocol <NSObject>

@property (nonatomic) THBEditModel *editModel;
@end

NS_ASSUME_NONNULL_END
