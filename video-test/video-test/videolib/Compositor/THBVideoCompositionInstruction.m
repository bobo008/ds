
#import "THBVideoCompositionInstruction.h"

@interface THBVideoCompositionInstruction () {
    @private
    BOOL _enablePostProcessing;
    BOOL _containsTweening;
}
@end

@implementation THBVideoCompositionInstruction

- (instancetype)init {
    if (self = [super init]) {
        _timeRange = kCMTimeRangeZero;
        _enablePostProcessing = YES; // For animationTool
        _containsTweening = NO;
        _composeTrackIDs = nil;
    }
    return self;
}

- (CMTimeRange)timeRange {
    return _timeRange;
}

- (BOOL)enablePostProcessing {
    return _enablePostProcessing;
}

- (BOOL)containsTweening {
    return _containsTweening;
}

- (NSArray<NSValue *> *)requiredSourceTrackIDs {
    return _composeTrackIDs;
}

- (CMPersistentTrackID)passthroughTrackID {
    return kCMPersistentTrackID_Invalid;
}

@end
