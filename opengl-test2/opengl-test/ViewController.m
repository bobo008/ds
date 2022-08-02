//
//  ViewController.m
//  opengl-test
//
//  Created by tanghongbo on 2022/7/6.
//

#import "ViewController.h"

#import "THBGestTestVC.h"

#import "PXCShadowTestVC.h"

#import "THBTBNLightTestVC.h"

#import "THBLightTestVC.h"

#import "THBLightShadowTestVC.h"

#import "THBContext.h"


#import "THBMSAARenderNode.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    
}

- (IBAction)onBtn:(id)sender {
    
//    THBLightShadowTestVC *vc = [[THBLightShadowTestVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Cutout_002.jpg" ofType:nil];
    CVPixelBufferRef pixel = [THBPixelBufferUtil pixelBufferForLocalURL:[NSURL fileURLWithPath:path]];
    
    
    THBMSAARenderNode *renderNode = [[THBMSAARenderNode alloc] init];
    renderNode.input = pixel;
    [renderNode render];
}

@end
