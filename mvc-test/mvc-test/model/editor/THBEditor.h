

#import <Foundation/Foundation.h>

#import "THBEditModel.h"
#import "THBData.h"


#import "THBDataProtocol.h"
#import "THBRenderProtocol.h"
#import "THBEditModelProtocol.h"
#import "THBUndoManagerProtocol.h"

/// 使用协议将各个职责分开
NS_ASSUME_NONNULL_BEGIN

@interface THBEditor : NSObject <THBUndoManagerProtocol, THBRenderProtocol, THBDataProtocol, THBEditModelProtocol>



- (void)install:(THBData *)data editModel:(THBEditModel *)editModel;

- (void)uninstall;


@end

NS_ASSUME_NONNULL_END
