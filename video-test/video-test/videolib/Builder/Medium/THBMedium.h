
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface THBMedium : NSObject
@property (nonatomic) NSURL *URL;
@property (nonatomic) CMPersistentTrackID trackID;
@property (nonatomic) CMTimeRange sourceTimeRange;
@property (nonatomic) CMTime activeOneLoopDuration;
@property (nonatomic) CMTimeRange activeTimeRange;
@property (nonatomic, nullable) id context;
@property (nonatomic) CMPersistentTrackID composeTrackID;

@property (nonatomic) NSArray<NSValue *> *sourceDurationArray;
@property (nonatomic) NSArray<NSValue *> *targetDurationArray;


@property (nonatomic) BOOL dontCorrectTime; /// 不需要修正时间

@end

NS_ASSUME_NONNULL_END
