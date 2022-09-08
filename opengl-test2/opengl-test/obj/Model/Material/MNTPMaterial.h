
#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNTPMaterial : NSObject <NSCopying>

@property (nonatomic) vector_float3 ambientColor;   /// default is (0.2, 0.2, 0.2)
@property (nonatomic) vector_float3 diffuseColor;   /// default is (0.8, 0.8, 0.8)
@property (nonatomic) vector_float3 specularColor;  /// default is (1.0, 1.0, 1.0)
@property (nonatomic) float shininess;              /// default is 0.0
@property (nonatomic) float alpha;

@property (nonatomic) NSString *map_kd;

@end

NS_ASSUME_NONNULL_END
