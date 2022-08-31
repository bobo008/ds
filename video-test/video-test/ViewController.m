//
//  ViewController.m
//  video-test
//
//  Created by tanghongbo on 2022/8/11.
//

#import "ViewController.h"

#import "THBVideoTestVC.h"

#import "THBContext.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onBtn:(id)sender {
//    THBVideoTestVC *vc = [[THBVideoTestVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    for (int i = 0; i < 100; i++) {
        int size = i + 4000;
        CVPixelBufferRef pixel = [THBPixelBufferUtil pixelBufferForWidth:size height:size];
        GLuint texture = [THBPixelBufferUtil textureForPixelBuffer:pixel];
        
        glDeleteTextures(1, &texture);
        CVPixelBufferRelease(pixel);
    }
    
//    glFinish();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CVOpenGLESTextureCacheFlush([GPUImageContext sharedImageProcessingContext].coreVideoTextureCache, 0);
//    });
    

    
    NSLog(@"222");
}


@end
