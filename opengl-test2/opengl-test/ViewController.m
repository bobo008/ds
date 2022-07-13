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


#import "THBContext.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    THBTBNLightTestVC *vc = [[THBTBNLightTestVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
    {
        simd_float2 B = simd_make_float2(0,0.5);
        simd_float2 A = simd_make_float2(0.5,0);
        simd_float2 C = simd_make_float2(1,0.6);
        
        simd_float2 edge1 = C - A;//E1
        simd_float2 edge2 = B - A;//E2
        simd_float2 uv1 = C - A;//纹理坐标向量
        simd_float2 uv2 = B - A;//纹理坐标向量

        simd_float2x2 T2 = {
            simd_make_float2(uv1.x, uv1.y),
            simd_make_float2(uv2.x, uv2.y),
        };
        
        simd_float2x3 TTT2 = {
            simd_make_float3(edge1, 0),
            simd_make_float3(edge2, 0),
        };

        simd_float3x2 ret2 = simd_mul(simd_inverse(simd_transpose(T2)),simd_transpose(TTT2));
        NSLog(@"22222");
        
        
        
    }
    
 
}


@end
