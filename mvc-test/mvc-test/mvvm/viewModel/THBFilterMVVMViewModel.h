
#import <UIkit/UIkit.h>

#import "THBEditor.h"

#import "THBFilterMVVMView.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBFilterMVVMViewModel : NSObject <THBFilterMVVMViewModelProtocol>

- (instancetype)initWithEditor:(THBEditor *)editor;


- (void)enterFilterEdit;
- (void)quitFilterEdit;
@end

NS_ASSUME_NONNULL_END
