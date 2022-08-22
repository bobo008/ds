
#import "THBAVFoundationUtil.h"

#pragma mark -
AVURLAsset * THBReadAssetFromPath(NSString *path) {
    return THBReadAssetFromURL([NSURL fileURLWithPath:path]);
}

AVURLAsset * THBReadAssetFromURL(NSURL *URL) {
    dispatch_semaphore_t locker = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(locker, DISPATCH_TIME_NOW);
    NSDictionary *options = @{
        AVURLAssetPreferPreciseDurationAndTimingKey: @(YES),
    };
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:options];
    NSString *key = NSStringFromSelector(@selector(tracks));
    [asset loadValuesAsynchronouslyForKeys:@[key] completionHandler:^{
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            NSError *error;
            AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:key error:&error];
            if (tracksStatus == AVKeyValueStatusLoaded || tracksStatus == AVKeyValueStatusFailed || tracksStatus == AVKeyValueStatusCancelled) {
                dispatch_semaphore_signal(locker);
            }
        });
    }];
    dispatch_semaphore_wait(locker, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(locker);
    locker = nil;
    
    NSError *checkTrackStatusError;
    AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:key error:&checkTrackStatusError];
    if (tracksStatus != AVKeyValueStatusLoaded) {
        NSLog(@"readAssetFromURL load tracks error");
        return nil;
    }
    return asset;
}

#pragma mark -
UIImage * THBReadAssetFrameAtTimeZero(AVURLAsset *asset, CGSize maximumSize) {
    return THBReadAssetFrameAtTime(asset, kCMTimeZero, maximumSize);
}

UIImage * THBReadAssetFrameAtTime(AVURLAsset *asset, CMTime time, CGSize maximumSize) {
    UIImage *image;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    if (maximumSize.width * maximumSize.height > 1) {
        generator.maximumSize = maximumSize;
    }
    NSError *error;
    CGImageRef cgImage = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (cgImage) {
        CGImageRef cgImage2 = CGImageCreateCopyWithColorSpace(cgImage, CGColorSpaceCreateWithName(kCGColorSpaceSRGB));
        CGImageRelease(cgImage);
        image = [UIImage imageWithCGImage:cgImage2 scale:1.0 orientation:UIImageOrientationUp];
        CGImageRelease(cgImage2);
    } else {
#ifdef DEBUG
        NSString *timeString = [NSString stringWithFormat:@"(%lld, %d -> %f)", time.value, time.timescale, CMTimeGetSeconds(time)];
        NSLog(@"read asset image at time: %@, error: %@", timeString, error);
#endif
    }
    
    return image;
}

#pragma mark -
UIImageOrientation THBOrientationWithAssetTrack(AVAssetTrack *assetTrack) {
    return THBOrientationWithAffineTransform(assetTrack.preferredTransform);
}

UIImageOrientation THBOrientationWithAffineTransform(CGAffineTransform transform) {
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        return UIImageOrientationRight;
    }
    
    if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        return UIImageOrientationLeft;
    }
    
    if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        return UIImageOrientationUp;
    }
    
    if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        return UIImageOrientationDown;
    }
    
    NSCAssert(NO, @"未知的Transform Orientation类型: %@", NSStringFromCGAffineTransform(transform));
    return UIImageOrientationUp;
}

CGSize THBSizeWithAsset(AVAsset *asset) {
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize result = CGSizeZero;
    if (videoTrack) {
        CGSize size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
        result = CGSizeMake(round(ABS(size.width)), round(ABS(size.height)));
    }
    return result;
}

#pragma mark -
THBAssetCompatible _SEPIsCompatibleAudioAssetTrack(AVAssetTrack *track) {
    NSArray *formatDescriptions = track.formatDescriptions;
    if (formatDescriptions.count > 0) {
        for (int i = 0; i < formatDescriptions.count; i++) {
            CMAudioFormatDescriptionRef formatDescription = (__bridge CMAudioFormatDescriptionRef)(formatDescriptions[i]);
            FourCharCode mediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription);
            if (mediaSubType == kAudioFormatAMR || mediaSubType == kAudioFormatAMR_WB || mediaSubType == kAudioFormatMPEGLayer2) {
                return THBAssetCompatible_UnsupportedCodecType;
            }
        }
    }
    return THBAssetCompatible_OK;
}

THBAssetCompatible _SEPIsCompatibleVideoAssetTrack(AVAssetTrack *track) {
    return THBAssetCompatible_OK;
}

THBAssetCompatible THBIsCompatibleAsset(AVURLAsset *asset) {
    {
        NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        for (AVAssetTrack *track in videoTracks) {
            THBAssetCompatible status = THBIsCompatibleAssetTrack(track);
            if (status != THBAssetCompatible_OK) {
                return status;
            }
        }
    } {
        NSArray<AVAssetTrack *> *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        for (AVAssetTrack *track in audioTracks) {
            THBAssetCompatible status = THBIsCompatibleAssetTrack(track);
            if (status != THBAssetCompatible_OK) {
                return status;
            }
        }
    }
    return THBAssetCompatible_OK;
}

THBAssetCompatible THBIsCompatibleAssetTrack(AVAssetTrack *track) {
    if ([track.mediaType isEqualToString:AVMediaTypeAudio]) {
        return _SEPIsCompatibleAudioAssetTrack(track);
    } else if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
        return _SEPIsCompatibleVideoAssetTrack(track);
    }
    return THBAssetCompatible_OK;
}

#pragma mark -
inline CGRect THBMakeRectWithAspectRatioFillRect(CGSize aspectRatio, CGRect boundingRect) {
    CGFloat w1 = aspectRatio.width, h1 = aspectRatio.height;
    if (w1 == 0 || h1 == 0) {
        return CGRectNull;
    }
    
    CGFloat w2 = CGRectGetWidth(boundingRect), h2 = CGRectGetHeight(boundingRect);
    if (w2 == 0 || h2 == 0) {
        return CGRectNull;
    }
    
    CGFloat w, h;
    if (w1 / h1 > w2 / h2) {
        h = h2;
        w = h * w1 / h1;
    } else {
        w = w2;
        h = w * h1 / w1;
    }
    CGFloat x, y;
    x = boundingRect.origin.x + (w2 - w) * 0.5;
    y = boundingRect.origin.y + (h2 - h) * 0.5;
    
    return CGRectMake(x, y, w, h);
}

CGRect THBMakeRectWithAspectRatioFitRect(CGSize aspectRatio, CGRect boundingRect) {
    return AVMakeRectWithAspectRatioInsideRect(aspectRatio, boundingRect);
}
