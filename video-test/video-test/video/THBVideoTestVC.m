//
//  THBVideoTestVC.m
//  video-test
//
//  Created by tanghongbo on 2022/8/11.
//

#import "THBVideoTestVC.h"

#import "THBAVFoundationUtil.h"

#import "THBBuilder.h"
#import "THBVideoCompositor.h"


#import "EAVVideoRenderer.h"

@interface THBVideoTestVC ()

@property (nonatomic) EAVVideoRenderer *renderer;

@property (nonatomic) THBBuilder *builder;
@property (nonatomic) NSMutableDictionary<NSString *, id> *composeTrackIdMap;


@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIView *showVideoView;

@end

@implementation THBVideoTestVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}



- (void)setup {
    _builder = [[THBBuilder alloc] init];
    [_builder install];
    [_builder updateCustomVideoCompositorClass:THBVideoCompositor.class];
    
    _composeTrackIdMap = [NSMutableDictionary dictionary];
    
    
    _renderer = [[EAVVideoRenderer alloc] init];
    
    [THBVideoCompositor setVideoRender:_renderer];
    
    [self _rebuildComposition];
    
    
    
    


    
    AVComposition *composition = self.builder.currentComposition;
    AVVideoComposition *videoComposition = self.builder.currentVideoComposition;
    AVAudioMix *audioMix = self.builder.currentAudioMix;
    
    NSArray<NSString *> *assetKeys = @[@"duration", @"playable"];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition automaticallyLoadedAssetKeys:assetKeys];
    playerItem.videoComposition = videoComposition;
    playerItem.audioMix = audioMix;
    
    playerItem.seekingWaitsForVideoCompositionRendering = YES;
    
    
    self.playerItem = playerItem;
    
    
    self.player = ({
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        player.automaticallyWaitsToMinimizeStalling = YES;
        player;
    });
    
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];

    self.playerLayer.frame = CGRectMake(0, 0, 375, 200);
    [self.showVideoView.layer addSublayer:self.playerLayer];
    [self.player play];
    
}



- (void)_rebuildComposition {
    [_composeTrackIdMap removeAllObjects];
    
    [self _rebuildCompositionVideo];
    [self _rebuildCompositionAudio];
    [self _rebuildAudioMix];
    
    NSDictionary<NSString *, id> *composeTrackIdMap = [_composeTrackIdMap copy];
    self->_renderer.renderComposeTrackIdMap = composeTrackIdMap;
}

- (void)_rebuildCompositionVideo {

    CMTime duration = CMTimeMake(600, 60);
    
    NSMutableArray<THBVideoMedium *> *mediums = [NSMutableArray array];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fullmoon_01.mp4" ofType:nil];
    
    AVAsset *asset = THBReadAssetFromPath(path);
    AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    
    THBVideoMedium *medium = [[THBVideoMedium alloc] init];
    medium.URL = [NSURL fileURLWithPath:path];
    medium.trackID = videoAssetTrack.trackID;
    medium.sourceTimeRange = videoAssetTrack.timeRange;
    medium.activeTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(600, 60));
    medium.activeOneLoopDuration = videoAssetTrack.timeRange.duration;
    medium.context = @"fullmoon_01";
    medium.composeTrackID = kCMPersistentTrackID_Invalid;
    [mediums addObject:medium];
    
    
    [_builder rebuildVideoTracks:mediums.copy duration:duration assignBlock:^(THBVideoMedium * _Nonnull medium) {
        if (medium.context) {
            [self.composeTrackIdMap setObject:@(medium.composeTrackID) forKey:medium.context];
        }
    }];
}


- (void)_rebuildCompositionAudio {
    CMTime duration = CMTimeMake(600, 60);
//    NSArray<THBAudioMedium *> *mediums = [T eav_flatten];
    [_builder rebuildAudioTracks:@[] duration:duration assignBlock:^(THBAudioMedium * _Nonnull medium) {
        if (medium.context) {
            [self.composeTrackIdMap setObject:@(medium.composeTrackID) forKey:medium.context];
        }
    }];
}

- (void)_rebuildAudioMix {
    [_builder rebuildAudioMix:@[]];
}







- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
