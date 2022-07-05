

#import <Foundation/Foundation.h>

#import "THBEditModel.h"
#import "THBData.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBEditor : NSObject

@property (nonatomic) THBData *data;
@property (nonatomic) THBEditModel *editModel;

- (void)install:(THBData *)data editModel:(THBEditModel *)editModel;

- (void)uninstall;


/// 数据



/// undo redo 模块


/// 渲染模块

@end

NS_ASSUME_NONNULL_END
