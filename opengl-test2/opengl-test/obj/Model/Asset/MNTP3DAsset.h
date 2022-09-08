
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MNTPMesh, MNTTransform;

@interface MNTP3DAsset : NSObject

- (instancetype)initWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;

@property (nonatomic) MNTPMesh *mesh;

/// up for res, below for layer

@property (nonatomic) MNTTransform *transform;

@property (nonatomic, nullable) NSString *globalLayerID;

@property (nonatomic, assign, getter=isBufferLoaded) BOOL bufferLoaded;

@property (nonatomic, readonly) uint32_t vertexGLBuffer;

- (uint32_t)indexGLBufferAtIndex:(NSUInteger)index;
- (uint32_t)indexGLBufferCountAtIndex:(NSUInteger)index;

- (void)loadBufferForGL;
- (void)bindBufferForGL;
- (void)detachBufferForGL;
@end



NS_ASSUME_NONNULL_END
