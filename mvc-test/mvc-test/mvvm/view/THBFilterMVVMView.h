
#import <UIKit/UIKit.h>




@protocol THBFilterMVVMViewModelProtocol <NSObject>

@property int seletIndex;

- (void)selectItem:(NSDictionary *)dict;

- (NSArray *)obtainArray;

@end




@interface THBFilterMVVMView : UIView



- (instancetype)initWithFrame:(CGRect)frame persenter:(id<THBFilterMVVMViewModelProtocol>) persenter;

@end


