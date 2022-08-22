
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface THBVideoCompositionInstruction : NSObject <AVVideoCompositionInstruction>
@property (nonatomic) NSArray<NSValue *> *composeTrackIDs;
@property (nonatomic) CMTimeRange timeRange;
@end

NS_ASSUME_NONNULL_END
