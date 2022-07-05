
#import <UIkit/UIkit.h>

#import "THBEditor.h"

#import "THBFilterMVPView.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBFilterMVPPersenter : NSObject <THBFilterMVPPersenterProtocol>

- (instancetype)initWithEditor:(THBEditor *)editor;

@end

NS_ASSUME_NONNULL_END
