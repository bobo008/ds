

#import "THBFilterMVPController.h"

#import "THBFilterMVPView.h"
#import "THBFilterMVPPersenter.h"

@interface THBFilterMVPController ()
@property (nonatomic) THBFilterMVPPersenter *persenter;

@property (nonatomic) THBFilterMVPView *view;
@end

@implementation THBFilterMVPController




- (void)setup {
    THBFilterMVPPersenter *persenter = [[THBFilterMVPPersenter alloc] init];
    
    THBFilterMVPView *view = [[THBFilterMVPView alloc] initWithFrame:self.frame persenter:persenter];

    [self.superView addSubview:view];
    
    self.persenter = persenter;
    self.view = view;
}



@end
