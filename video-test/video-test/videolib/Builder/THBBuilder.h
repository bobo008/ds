
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "THBVideoMedium.h"
#import "THBAudioMedium.h"
#import "THBAudioMixMedium.h"

NS_ASSUME_NONNULL_BEGIN

@interface THBBuilder : NSObject
@property (nonatomic, readonly) AVComposition *currentComposition;
@property (nonatomic, readonly) AVVideoComposition *currentVideoComposition;
@property (nonatomic, readonly) AVAudioMix *currentAudioMix;

- (void)install;
- (void)uninstall;

- (void)changeFrameDuration:(CMTime)frameDuration;
- (void)changeRenderSize:(CGSize)renderSize;

- (void)rebuildVideoTracks:(NSArray<THBVideoMedium *> *)mediums duration:(CMTime)duration assignBlock:(void (^)(THBVideoMedium *medium))assignBlock;
- (void)rebuildAudioTracks:(NSArray<THBAudioMedium *> *)mediums duration:(CMTime)duration assignBlock:(void (^)(THBAudioMedium *medium))assignBlock;
- (void)rebuildAudioMix:(NSArray<THBAudioMixMedium *> *)mediums;

- (void)updateCustomVideoCompositorClass:(Class<AVVideoCompositing>)customCls;

@end

NS_ASSUME_NONNULL_END
