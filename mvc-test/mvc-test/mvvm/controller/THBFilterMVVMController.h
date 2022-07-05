

#import <UIKit/UIKit.h>
#import "THBEditor.h"
NS_ASSUME_NONNULL_BEGIN

@interface THBFilterMVVMController : NSObject

@property (nonatomic) UIView *superView;
@property (nonatomic) CGRect frame;
@property (nonatomic) THBEditor *editor;

- (void)install;
- (void)uninstall;

@end

NS_ASSUME_NONNULL_END
