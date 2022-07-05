
#import <UIkit/UIkit.h>

#import "THBEditor.h"

#import "THBFilterMVVMView.h"

#import "THBDataProtocol.h"
#import "THBRenderProtocol.h"
#import "THBEditModelProtocol.h"
#import "THBUndoManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBFilterMVVMViewModel : NSObject <THBFilterMVVMViewModelProtocol>

- (instancetype)initWithEditor:(id<THBDataProtocol, THBEditModelProtocol>)editor;


- (void)enterFilterEdit;
- (void)quitFilterEdit;
@end

NS_ASSUME_NONNULL_END
