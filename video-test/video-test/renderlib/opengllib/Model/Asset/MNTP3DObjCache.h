//  Created on 2021/12/29.

#import <Foundation/Foundation.h>

@class MNTP3DAsset;
@class THBTexture;

NS_ASSUME_NONNULL_BEGIN

@interface MNTP3DObjCache : NSObject

+ (void)cacheAsset:(MNTP3DAsset *)asset withObjPath:(NSString *)path;
+ (nullable MNTP3DAsset *)getAssetForPath:(NSString *)path;

+ (void)cacheTexture:(THBTexture *)texture forMatrialPath:(NSString *)path;
+ (nullable THBTexture *)getTextureForMatrialPath:(NSString *)path;

+ (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
