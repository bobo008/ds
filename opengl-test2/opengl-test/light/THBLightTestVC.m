
#import "THBLightTestVC.h"

#import "THBTestRenderer.h"


#import "UIImage+EAVExtend.h"


@interface THBLightTestVC ()

@property (weak, nonatomic) IBOutlet UIView *renderView;
@property (nonatomic) UIImageView *imageView;
@end

@implementation THBLightTestVC




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 375)];

    [self.renderView addSubview:imageView];
    self.imageView = imageView;
    
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 375, 375)];

    [self.view addSubview:imageView2];

    
    
    THBTestRenderer *render = [[THBTestRenderer alloc] init];
    
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        [render setup];
        THBGLESTexture *texture = [render drawCanvas];
        
        UIImage *resultImage = [THBPixelBufferUtil imageForPixelBuffer:texture.pixel];
//        resultImage = [resultImage cxx_flipImage];
        
        self.imageView.image = resultImage;
        [render dispose];
    }];
    

    
    
}








- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}



@end
