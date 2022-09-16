//
//  THBPerson.h
//  video-test
//
//  Created by tanghongbo on 2022/9/14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <simd/simd.h>

#import "THBDog.h"
#import "THBBigDog.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBPerson : NSObject


//@property (nonatomic) NSString *name;
//
//@property (nonatomic) BOOL woman;

//@property (nonatomic) CGRect rect;

//@property (nonatomic) double weight;


//@property (nonatomic) CGPoint point;


//@property (nonatomic) simd_float2 center22;



@property (nonatomic) THBPerson *person;

@property (nonatomic) THBDog *dog;

@property (nonatomic) NSArray<THBDog *> *dogs;

//@property (nonatomic) CMTimeRange timeRange;


- (void)test;

@end

NS_ASSUME_NONNULL_END
