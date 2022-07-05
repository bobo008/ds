//
//  ViewController.m
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import "ViewController.h"

#import "THBMvcTestVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    THBMvcTestVC *vc = [[THBMvcTestVC alloc] init];

    [self.navigationController pushViewController:vc animated:YES];
}


@end
