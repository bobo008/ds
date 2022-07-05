
#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN
/// 用作跨view的通信用
@interface THBEditModel : NSObject


@property (nonatomic) NSMutableArray *array;
@property (nonatomic) NSString *currentEditItem;

@end

NS_ASSUME_NONNULL_END
