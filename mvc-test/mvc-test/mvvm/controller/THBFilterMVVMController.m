

#import "THBFilterMVVMController.h"

#import "THBFilterMVVMView.h"
#import "THBFilterMVVMViewModel.h"

@interface THBFilterMVVMController ()
@property (nonatomic) THBFilterMVVMViewModel *viewModel;

@property (nonatomic) THBFilterMVVMView *view;
@end

@implementation THBFilterMVVMController




- (void)setup {
    THBFilterMVVMViewModel *viewModel = [[THBFilterMVVMViewModel alloc] init];
    
    THBFilterMVVMView *view = [[THBFilterMVVMView alloc] initWithFrame:self.frame persenter:viewModel];

    [self.superView addSubview:view];
    
    self.viewModel = viewModel;
    self.view = view;
}



@end
