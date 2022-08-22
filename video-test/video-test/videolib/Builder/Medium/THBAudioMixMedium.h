
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBAudioMixVolumePoint : NSObject
@property (nonatomic) CMTime time;
@property (nonatomic) float volume;
@end

@interface THBAudioMixMedium : NSObject
@property (nonatomic) CMPersistentTrackID composeTrackID;
@property (nonatomic) AVAudioTimePitchAlgorithm audioTimePitchAlgorithm;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) NSArray<THBAudioMixVolumePoint *> *volumePoints;
@end

NS_ASSUME_NONNULL_END
