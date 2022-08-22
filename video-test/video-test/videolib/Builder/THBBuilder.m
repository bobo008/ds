
#import "THBBuilder.h"
#import "THBVideoCompositor.h"
#import "THBVideoCompositionInstruction.h"
#import "THBContext.h"

#import "THBAVFoundationUtil.h"

#import "NSArray+THBExtend.h"


#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

@interface THBBuilder ()
@property (nonatomic) NSURL *bonusVideoURL;
@property (nonatomic) CMPersistentTrackID bonusVideoTrackID;
@property (nonatomic) CMTime bonusVideoDuration;

@property (nonatomic) AVMutableComposition *composition;
@property (nonatomic) AVMutableVideoComposition *videoComposition;
@property (nonatomic) AVMutableAudioMix *audioMix;
@end

@implementation THBBuilder

#pragma mark -
- (void)install {
    @autoreleasepool {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"video_60.mov" ofType:nil];
        AVURLAsset *asset = THBReadAssetFromPath(path);
        _bonusVideoURL = [NSURL fileURLWithPath:path];
        _bonusVideoTrackID = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.trackID;
        _bonusVideoDuration = asset.duration;
    }
    
    NSDictionary *options = @{
        AVURLAssetPreferPreciseDurationAndTimingKey: @(YES),
    };
    _composition = [AVMutableComposition compositionWithURLAssetInitializationOptions:options];
    _composition.naturalSize = CGSizeMake(1920, 1080);
    
    _videoComposition = [[AVMutableVideoComposition alloc] init];
    _videoComposition.customVideoCompositorClass = [THBVideoCompositor class];
    _videoComposition.frameDuration = CMTimeMake(1, 30);
    _videoComposition.renderSize = CGSizeMake(1920, 1080);
    _videoComposition.renderScale = 1;
    _videoComposition.instructions = @[[[THBVideoCompositionInstruction alloc] init]];
    _videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2;
    _videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2;
    _videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2;
    if (@available(iOS 11.0.0, *)) {
        _videoComposition.sourceTrackIDForFrameTiming = kCMPersistentTrackID_Invalid;
    }
    
    _audioMix = [AVMutableAudioMix audioMix];
    _audioMix.inputParameters = @[];
}

- (void)uninstall {
    _composition = nil;
    _videoComposition = nil;
    _audioMix = nil;
}

#pragma mark -
- (void)changeFrameDuration:(CMTime)frameDuration {
#ifdef DEBUG
//    NSLog(@"change frameDuration: %@", NSStringFromCMTime(frameDuration));
#endif
    if (CMTIME_IS_VALID(frameDuration) && CMTIME_COMPARE_INLINE(_videoComposition.frameDuration, !=, frameDuration)) {
        _videoComposition.frameDuration = frameDuration;
    }
}

- (void)changeRenderSize:(CGSize)renderSize {
#ifdef DEBUG
    NSLog(@"change renderSize: %@", NSStringFromCGSize(renderSize));
#endif
    if (renderSize.width * renderSize.height >= 1) {
        if (!CGSizeEqualToSize(_composition.naturalSize, renderSize)) {
            _composition.naturalSize = renderSize;
        }
        if (!CGSizeEqualToSize(_videoComposition.renderSize, renderSize)) {
            _videoComposition.renderSize = renderSize;
        }
    }
}

- (void)updateCustomVideoCompositorClass:(Class<AVVideoCompositing>)customCls {
    self.videoComposition.customVideoCompositorClass = customCls;
}

#pragma mark -
- (void)_rebuildVideoTracks:(NSArray<THBVideoMedium *> *)mediums assignBlock:(void (^)(THBVideoMedium * _Nonnull))assignBlock {
    NSArray<AVMutableCompositionTrack *> *tracks = [_composition tracksWithMediaType:AVMediaTypeVideo];
    for (int i = 0; i < tracks.count; i++) {
        tracks[i].segments = @[];
    }
    
    int maximumTrackIndex = -1;
    for (int idx = 0; idx < mediums.count; idx++) {
        THBVideoMedium *medium = mediums[idx];
        
        int useTrackIndex = 0;
        while (YES) {
            AVMutableCompositionTrack *track;
            if (tracks.count == useTrackIndex) {
                track = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                if (!track) {
#ifdef DEBUG
                    NSLog(@"无法创建更多的视频轨道");
#endif
                    break;
                }
                tracks = [tracks arrayByAddingObject:track];
            } else {
                track = tracks[useTrackIndex];
            }
            BOOL isEmpty = track.segments.count == 0;
            CMTime trackEndTime = isEmpty ? kCMTimeZero : CMTimeRangeGetEnd(track.segments.lastObject.timeMapping.target);
            int32_t compareResult = CMTimeCompare(trackEndTime, medium.activeTimeRange.start);
            BOOL isOK = isEmpty ? (compareResult != 1) : (compareResult == -1);
            if (isOK) {
                NSMutableArray<AVCompositionTrackSegment *> *segments = [NSMutableArray array];
                if (compareResult == -1) {
                    CMTimeRange timeRange = CMTimeRangeFromTimeToTime(trackEndTime, medium.activeTimeRange.start);
                    AVCompositionTrackSegment *segment = [AVCompositionTrackSegment compositionTrackSegmentWithTimeRange:timeRange];
                    [segments addObject:segment];
                }
                [self _concat:segments medium:medium];
                NSArray<AVCompositionTrackSegment *> *finalSegment = [track.segments ?: @[] arrayByAddingObjectsFromArray:segments];
                track.segments = finalSegment;
                medium.composeTrackID = track.trackID;
                assignBlock(medium);
                break;
            }
            useTrackIndex++;
        }
        maximumTrackIndex = MAX(maximumTrackIndex, useTrackIndex);
    }
    
    if (maximumTrackIndex < (int)tracks.count - 1) {
        for (int i = maximumTrackIndex + 1; i < tracks.count; i++) {
            [_composition removeTrack:tracks[i]];
        }
    }
}

- (void)rebuildVideoTracks:(NSArray<THBVideoMedium *> *)mediums duration:(CMTime)duration assignBlock:(void (^)(THBVideoMedium * _Nonnull))assignBlock {
#ifdef DEBUG
    NSLog(@"Rebuild前视频轨道数: %d", (int)[[_composition tracksWithMediaType:AVMediaTypeVideo] count]);
#endif
    
    mediums = [mediums sortedArrayUsingComparator:^NSComparisonResult(THBMedium *obj1, THBMedium *obj2) {
        return CMTimeCompare(obj1.activeTimeRange.start, obj2.activeTimeRange.start);
    }];
    
    if (CMTimeCompare(duration, kCMTimeZero) == 1) {
        mediums = [mediums THB_arrayByInsertObject:({
            CMTimeRange t = CMTimeRangeMake(kCMTimeZero, _bonusVideoDuration);
            THBVideoMedium *medium = [[THBVideoMedium alloc] init];
            medium.URL = _bonusVideoURL;
            medium.trackID = _bonusVideoTrackID;
            medium.sourceTimeRange = t;
            medium.activeOneLoopDuration = _bonusVideoDuration;
            medium.activeTimeRange = CMTimeRangeMake(kCMTimeZero, duration);
            medium.context = nil;
            medium.composeTrackID = kCMPersistentTrackID_Invalid;
            medium;
        }) atIndex:0];
    }
    
    [self _rebuildVideoTracks:mediums assignBlock:assignBlock];
    
    THBVideoCompositionInstruction *instruction = (THBVideoCompositionInstruction *)_videoComposition.instructions.firstObject;
    instruction.composeTrackIDs = [[_composition tracksWithMediaType:AVMediaTypeVideo] THB_arrayMap:^id _Nonnull(AVMutableCompositionTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return @(obj.trackID);
    }];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, _composition.duration);
    
#ifdef DEBUG
    NSLog(@"Rebuild后视频轨道数: %d", (int)[[_composition tracksWithMediaType:AVMediaTypeVideo] count]);
#endif
}

#pragma mark -
- (void)_rebuildAudioTracks:(NSArray<THBAudioMedium *> *)mediums assignBlock:(void (^)(THBAudioMedium * _Nonnull))assignBlock {
    NSArray<AVMutableCompositionTrack *> *tracks = [_composition tracksWithMediaType:AVMediaTypeAudio];
    for (int i = 0; i < tracks.count; i++) {
        tracks[i].segments = @[];
    }
    int32_t diff = (int32_t)mediums.count - (int32_t)tracks.count;
    if (diff > 0) {
        for (int32_t i = 0; i < diff; i++) {
            AVMutableCompositionTrack *track;
            track = [_composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            if (!track) {
#ifdef DEBUG
                NSLog(@"无法创建更多的音频轨道");
#endif
                break;
            }
            tracks = [tracks arrayByAddingObject:track];
        }
    } else if (diff < 0) {
        for (int32_t i = (int32_t)mediums.count; i < tracks.count; i++) {
            [_composition removeTrack:[tracks objectAtIndex:i]];
        }
        tracks = [tracks subarrayWithRange:NSMakeRange(0, mediums.count)];
    }
    
    for (int i = 0; i < tracks.count; i++) {
        THBAudioMedium *medium = [mediums objectAtIndex:i];
        
        int32_t compareResult = CMTimeCompare(medium.activeTimeRange.start, kCMTimeZero);
        if (compareResult == -1) {
            NSAssert(NO, nil);
            continue;
        }
        
        NSMutableArray<AVCompositionTrackSegment *> *segments = [NSMutableArray array];
        if (compareResult == 1) {
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, medium.activeTimeRange.start);
            [segments addObject:[AVCompositionTrackSegment compositionTrackSegmentWithTimeRange:timeRange]];
        }
        [self _concat:segments medium:medium];
        
        AVMutableCompositionTrack *track = [tracks objectAtIndex:i];
        track.segments = segments;
        medium.composeTrackID = track.trackID;
        assignBlock(medium);
    }
}

- (void)rebuildAudioTracks:(NSArray<THBAudioMedium *> *)mediums duration:(CMTime)duration assignBlock:(void (^)(THBAudioMedium * _Nonnull))assignBlock {
#ifdef DEBUG
    NSLog(@"Rebuild前音频轨道数: %d", (int)[[_composition tracksWithMediaType:AVMediaTypeAudio] count]);
#endif
    
    mediums = [mediums sortedArrayUsingComparator:^NSComparisonResult(THBMedium *obj1, THBMedium *obj2) {
        return CMTimeCompare(obj1.activeTimeRange.start, obj2.activeTimeRange.start);
    }];
    
    [self _rebuildAudioTracks:mediums assignBlock:assignBlock];
    
#ifdef DEBUG
    NSLog(@"Rebuild后音频轨道数: %d", (int)[[_composition tracksWithMediaType:AVMediaTypeAudio] count]);
#endif
}

#pragma mark -
- (void)rebuildAudioMix:(NSArray<THBAudioMixMedium *> *)mediums {
    NSMutableDictionary<NSNumber *, AVMutableAudioMixInputParameters *> *inputParametersMap = [NSMutableDictionary dictionary];
    
    [mediums enumerateObjectsUsingBlock:^(THBAudioMixMedium * _Nonnull medium, NSUInteger idx, BOOL * _Nonnull stop) {
        CMPersistentTrackID trackID = medium.composeTrackID;
        if (trackID == kCMPersistentTrackID_Invalid) return;
        AVMutableAudioMixInputParameters *inputParameters = [inputParametersMap objectForKey:@(trackID)];
        if (!inputParameters) {
            inputParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
            inputParameters.trackID = trackID;
            inputParameters.audioTimePitchAlgorithm = medium.audioTimePitchAlgorithm;
            [inputParametersMap setObject:inputParameters forKey:@(trackID)];
        }
//        [inputParameters setVolume:medium.volumePoints.firstObject.volume atTime:CMTimeMake(-1 * kTHBPreferredTimescale, kTHBPreferredTimescale)];
//        for (THBAudioMixVolumePoint *volumePoint in medium.volumePoints) {
//            [inputParameters setVolume:volumePoint.volume atTime:CMTimeAdd(medium.timeRange.start, volumePoint.time)];
//        }
        /// 上面这一套渐入渐出有问题，估计是系统api的问题，只能改成下面这个版本
        [inputParameters setVolume:medium.volumePoints.firstObject.volume atTime:CMTimeAdd(medium.timeRange.start, medium.volumePoints.firstObject.time)];
        for (NSInteger i = 1; i < medium.volumePoints.count; i++) {
            assert(CMTIME_COMPARE_INLINE(medium.volumePoints[i - 1].time, <=, medium.volumePoints[i].time));
            [inputParameters setVolumeRampFromStartVolume:medium.volumePoints[i - 1].volume toEndVolume:medium.volumePoints[i].volume timeRange:CMTimeRangeMake(CMTimeAdd(medium.timeRange.start, medium.volumePoints[i - 1].time), CMTimeSubtract(medium.volumePoints[i].time, medium.volumePoints[i - 1].time))];
        }
    }];
    
    _audioMix.inputParameters = [inputParametersMap allValues];
}

#pragma mark -
- (void)_concat:(NSMutableArray<AVCompositionTrackSegment *> *)segments medium:(THBMedium *)medium {
    if (medium.sourceDurationArray.count > 0) {
        NSArray *sourceTimeRanges = medium.sourceDurationArray;
        NSArray *targetTimeRanges = medium.targetDurationArray;
        CMTime sourceStart = medium.sourceTimeRange.start;
        CMTime targetStart = segments.count > 0 ? CMTimeRangeGetEnd(segments.lastObject.timeMapping.target) : medium.activeTimeRange.start;
        CMTime sourceTimeRangeEnd = CMTimeRangeGetEnd(medium.sourceTimeRange);
        for (int i = 0; i < sourceTimeRanges.count; ++i) {
            CMTime sourceDuration = [sourceTimeRanges[i] CMTimeValue];
            CMTime targetDuration = [targetTimeRanges[i] CMTimeValue];
            CMTime sourceEnd = CMTimeAdd(sourceStart, sourceDuration);
            if (CMTimeCompare(sourceEnd, sourceTimeRangeEnd) > 0) {
                sourceStart = CMTimeSubtract(sourceTimeRangeEnd, sourceDuration);
            }
            AVCompositionTrackSegment *segment = [AVCompositionTrackSegment compositionTrackSegmentWithURL:medium.URL
                                                                                                   trackID:medium.trackID
                                                                                           sourceTimeRange:CMTimeRangeMake(sourceStart, sourceDuration)
                                                                                           targetTimeRange:CMTimeRangeMake(targetStart, targetDuration)];
            [segments addObject:segment];
            sourceStart = CMTimeAdd(sourceStart, sourceDuration);
            targetStart = CMTimeRangeGetEnd(segments.lastObject.timeMapping.target);
        }
    }
    else {
        CMTime start = segments.count > 0 ? CMTimeRangeGetEnd(segments.lastObject.timeMapping.target) : medium.activeTimeRange.start;
        CMTime remain = medium.activeTimeRange.duration;
        while (CMTimeCompare(remain, kCMTimeZero) == 1) {
            CMTime targetDurationIdeal = medium.activeOneLoopDuration;
            CMTime targetDuration = CMTimeMinimum(targetDurationIdeal, remain);
            CMTime sourceDuration = medium.sourceTimeRange.duration;
            if (CMTimeCompare(targetDuration, targetDurationIdeal) != 0 && !medium.dontCorrectTime) {
                sourceDuration = CMTimeMapDurationFromRangeToRange(sourceDuration, CMTimeRangeMake(kCMTimeZero, targetDurationIdeal), CMTimeRangeMake(kCMTimeZero, targetDuration));
            }
            AVCompositionTrackSegment *segment = [AVCompositionTrackSegment compositionTrackSegmentWithURL:medium.URL
                                                                                                   trackID:medium.trackID
                                                                                           sourceTimeRange:CMTimeRangeMake(medium.sourceTimeRange.start, sourceDuration)
                                                                                           targetTimeRange:CMTimeRangeMake(start, targetDuration)];
            [segments addObject:segment];
            start = CMTimeRangeGetEnd(segments.lastObject.timeMapping.target);
            remain = CMTimeSubtract(remain, targetDuration);
        }
    }
}

#pragma mark -
- (AVComposition *)currentComposition {
    return _composition.copy;
}

- (AVVideoComposition *)currentVideoComposition {
    return _videoComposition.copy;
}

- (AVAudioMix *)currentAudioMix {
    return _audioMix.copy;
}

@end
