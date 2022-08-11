//
//  ViewController.m
//  video-test
//
//  Created by tanghongbo on 2022/8/11.
//

#import "ViewController.h"

#import "THBVideoTestVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onBtn:(id)sender {
    THBVideoTestVC *vc = [[THBVideoTestVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
