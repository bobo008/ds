

#import "THBFilterMVVMController.h"

#import "THBFilterMVVMView.h"
#import "THBFilterMVVMViewModel.h"

@interface THBFilterMVVMController ()
@property (nonatomic) THBFilterMVVMViewModel *viewModel;

@property (nonatomic) THBFilterMVVMView *view;
@end

@implementation THBFilterMVVMController




- (void)install {
    THBFilterMVVMViewModel *viewModel = [[THBFilterMVVMViewModel alloc] initWithEditor:self.editor];
    THBFilterMVVMView *view = [[THBFilterMVVMView alloc] initWithFrame:self.frame persenter:viewModel];
    [self.superView addSubview:view];
    self.viewModel = viewModel;
    self.view = view;
    
    [self.viewModel enterFilterEdit];
}


- (void)uninstall {
    [self.viewModel quitFilterEdit];
}

@end
