//
//  ViewController.m
//  video-test
//
//  Created by tanghongbo on 2022/8/11.
//

#import "ViewController.h"

#import "THBVideoTestVC.h"

#import "THBContext.h"

#import "MJExtension.h"

#import "THBPerson.h"

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
    
    
    

    
    
//    for (int i = 0; i < 100; i++) {
//        int size = i + 4000;
//        CVPixelBufferRef pixel = [THBPixelBufferUtil pixelBufferForWidth:size height:size];
//        GLuint texture = [THBPixelBufferUtil textureForPixelBuffer:pixel];
//
//        glDeleteTextures(1, &texture);
//        CVPixelBufferRelease(pixel);
//    }
    
//    glFinish();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CVOpenGLESTextureCacheFlush([GPUImageContext sharedImageProcessingContext].coreVideoTextureCache, 0);
//    });
    


    
    THBPerson *person = [[THBPerson alloc] init];

    person.person = [[THBPerson alloc] init];
    NSDictionary *dic = person.thb_keyValues;
    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    
    
    unsigned int outCount2 = 0;
    Ivar *ivars = class_copyIvarList([person class], &outCount2);
    
    for (int i = 0; i< outCount2; i++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        NSString *ivarName2 = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        ptrdiff_t offset = ivar_getOffset(ivar);

   


        struct SteveDate {
            float a;
            float b;
            float c;
            float d;
        };
        typedef struct SteveDate SteveDate;
        
        SteveDate float222 =  {1,1,2,3};
        simd_float3 a = simd_make_float3(float222.a,float222.b, float222.c);
        
        NSString *ivarName23 = [NSString stringWithUTF8String:@encode(SteveDate)];
        
        NSLog(@"%@",ivarName);
    }
    
    typedef struct{
        float a;
        float b;
    } float2;
    
    float2 float22 =  {1,1};
    
    
    
    
//    CGPoint point = CGPointMake(222, 333);
//    NSValue *stuValue = [NSValue valueWithBytes:&point objCType:@encode(CGPoint)];
//    [person setValue:stuValue forKey:@"point"];
    
    
    
    THBPerson *person2 = [[THBPerson alloc] init];
    [person2 test];
    [person2 thb_setKeyValues:dic];
    
    NSLog(@"2222");
    
    
}


@end
