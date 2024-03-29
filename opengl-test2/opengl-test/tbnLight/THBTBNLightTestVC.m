
#import "THBTBNLightTestVC.h"

#import "THBTBNTestRenderer.h"
#import "THBTestRenderer.h"

#import "UIImage+THBExtend.h"


@interface THBTBNLightTestVC ()

@property (weak, nonatomic) IBOutlet UIView *renderView;
@property (nonatomic) UIImageView *imageView;


@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;

@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;

@property (weak, nonatomic) IBOutlet UISlider *slider5;

@property (weak, nonatomic) IBOutlet UISlider *slider6;
@property (weak, nonatomic) IBOutlet UISlider *slider7;
@property (weak, nonatomic) IBOutlet UISlider *slider8;


@property (nonatomic) THBTBNTestRenderer *render;

@end

@implementation THBTBNLightTestVC




- (void)viewDidLoad {
    [super viewDidLoad];


    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 375)];

    [self.renderView addSubview:imageView];
    self.imageView = imageView;


    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 375, 375)];

    [self.view addSubview:imageView2];



    THBTBNTestRenderer *render = [[THBTBNTestRenderer alloc] init];
    self.render = render;

    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        [self.render setup];
    }];

    [self renderIfNeed];


    [self.slider1 setValue:self.render.scale];
    [self.slider2 setValue:0.5];
    [self.slider3 setValue:0.5];
    [self.slider4 setValue:0.5];
    
    
    [self.slider5 setValue:0.5];
    
}


- (void)dealloc {
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        [self.render dispose];
    }];
}


- (void)renderIfNeed {
    [[THBContext sharedInstance] runSyncOnRenderingQueue:^{
        THBTexture *texture = [self.render drawCanvas];
        
        UIImage *resultImage = [THBPixelBufferUtil imageForPixelBuffer:texture.pixel];
        resultImage = [resultImage cxx_flipImage];
        self.imageView.image = resultImage;
        
        [texture releaseGLESTexture];
    }];

}




- (IBAction)onReset:(id)sender {
    
    
    self.render.scale = 1;
    self.render.x = 0;
    self.render.y = 0;
    self.render.z = 0;
    [self renderIfNeed];
}










- (IBAction)valueChange:(UISlider *)slider {
    
    if (slider == self.slider1) {
        self.render.scale = slider.value;
        [self renderIfNeed];
    } else if (slider == self.slider2) {
        self.render.x = slider.value * M_PI * 2 - M_PI;
        [self renderIfNeed];
    } else if (slider == self.slider3) {
        self.render.y = slider.value * M_PI * 2 - M_PI;
        [self renderIfNeed];
    } else if (slider == self.slider4) {
        self.render.z = slider.value * M_PI * 2 - M_PI;
        [self renderIfNeed];
    } else if (slider == self.slider5) {
        self.render.light = slider.value * M_PI * 2 - M_PI;
        [self renderIfNeed];
    } else if (slider == self.slider6) {
        self.render.offset_x = slider.value * 6 - 3;
        [self renderIfNeed];
    } else if (slider == self.slider7) {
        self.render.offset_y = slider.value * 6 - 3;
        [self renderIfNeed];
    } else if (slider == self.slider8) {
        self.render.offset_z = slider.value * 6 - 3;
        [self renderIfNeed];
    }
    
    
    
}



















- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}



@end
