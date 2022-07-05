

#import <UIKit/UIKit.h>
#import "THBEditor.h"
NS_ASSUME_NONNULL_BEGIN

@interface THBFilterMVPController : NSObject

@property (nonatomic) UIView *superView;
@property (nonatomic) CGRect frame;
@property (nonatomic) THBEditor *editor;

- (void)setup;

@end

NS_ASSUME_NONNULL_END
