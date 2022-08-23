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

#import "THBMipmapRenderNode.h"

#import "THBMipmapMetalNode.h"

#import "THBMutiMetalNode.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    
}

- (IBAction)onBtn:(id)sender {
    
//    TTTEffectCreatorTestVC *vc = [[TTTEffectCreatorTestVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    [self test];
}


- (void)test {
    THBMutiMetalNode *renderNode = [[THBMutiMetalNode alloc] init];
    [renderNode render];
}
@end
