
#import <UIKit/UIKit.h>
#import "THBFilterManager.h"


@interface THBFilterView : UIView

@property (nonatomic, copy) void(^selectItem)(THBFilterModel *model);
@end


