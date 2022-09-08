
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MNTPMaterial;

@interface MNTPSubmesh : NSObject

@property (nonatomic) NSString *name;

@property (nonatomic, readonly) uint32_t *indexBuffer;

@property (nonatomic, readonly) NSUInteger indexCount;

@property (nonatomic) MNTPMaterial *material;

@property (nonatomic) NSString *baseColorName;
@property (nonatomic) NSURL *baseColorMapURL;

- (void)addIndex:(uint32_t)index;
- (void)removeLast;
- (void)updateIndexArray:(uint32_t *)indexArray count:(NSInteger)indexCount;

@end

NS_ASSUME_NONNULL_END
