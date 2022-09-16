//
//  THBPerson.m
//  video-test
//
//  Created by tanghongbo on 2022/9/14.
//

#import "THBPerson.h"


@implementation THBPerson

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"dogs" : @"THBDog"
    };
}


- (instancetype)init {
    self = [super init];
    if (self) {
//        _name = @"2222";
//        _woman = YES;
//        _rect = CGRectMake(20, 20, 111, 222);
//        _weight = 0.333;
//        _point = CGPointMake(120, 55);
//        _center22 = simd_make_float2(13., 11);
        _dog = [[THBDog alloc] init];
        _dogs = @[[[THBDog alloc] init], [[THBBigDog alloc] init]];
        
        _dog.name = @"sdasdasdasdasdasdasdas";
        
        _dogs.firstObject.name = @"22222222dasfvc2222";
        _dogs.lastObject.name = @"22sadasdsadsa2222222222";

//        _timeRange = CMTimeRangeMake(CMTimeMake(0, 600), CMTimeMake(6000, 600));
    }
    return self;
}


- (void)test {
    _dog = [[THBDog alloc] init];
    _dogs = @[[[THBDog alloc] init], [[THBBigDog alloc] init]];
}

@end
