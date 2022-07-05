
#import <UIKit/UIKit.h>


static NSNotificationName THBFilterMVPUpdateNotificaiton = @"thb.update.mvp.filter.view.notificaiton";

@protocol THBFilterMVPPersenterProtocol <NSObject>

- (void)selectItem:(NSDictionary *)dict;

- (NSArray *)obtainArray;

@end




@interface THBFilterMVPView : UIView



- (instancetype)initWithFrame:(CGRect)frame persenter:(id<THBFilterMVPPersenterProtocol>) persenter;

@end


