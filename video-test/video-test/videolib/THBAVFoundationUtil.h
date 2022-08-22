
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


AVURLAsset * THBReadAssetFromPath(NSString *path);
AVURLAsset * THBReadAssetFromURL(NSURL *URL);

UIImage * THBReadAssetFrameAtTimeZero(AVURLAsset *asset, CGSize maximumSize);
UIImage * THBReadAssetFrameAtTime(AVURLAsset *asset, CMTime time, CGSize maximumSize);

UIImageOrientation THBOrientationWithAssetTrack(AVAssetTrack *assetTrack);
UIImageOrientation THBOrientationWithAffineTransform(CGAffineTransform transform);

CGSize THBSizeWithAsset(AVAsset *asset);

typedef NS_ENUM(int, THBAssetCompatible) {
    THBAssetCompatible_OK = 0,
    THBAssetCompatible_UnknownError = 1,
    THBAssetCompatible_UnsupportedCodecType = 101,
};
THBAssetCompatible THBIsCompatibleAsset(AVURLAsset *asset);
THBAssetCompatible THBIsCompatibleAssetTrack(AVAssetTrack *track);

CGRect THBMakeRectWithAspectRatioFillRect(CGSize aspectRatio, CGRect boundingRect);
CGRect THBMakeRectWithAspectRatioFitRect(CGSize aspectRatio, CGRect boundingRect);
