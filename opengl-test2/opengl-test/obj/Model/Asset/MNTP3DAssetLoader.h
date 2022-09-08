
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MNTP3DAsset;
@interface MNTP3DAssetLoader : NSObject

- (MNTP3DAsset * _Nullable)loadAssetAtURL:(NSURL *)URL error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
