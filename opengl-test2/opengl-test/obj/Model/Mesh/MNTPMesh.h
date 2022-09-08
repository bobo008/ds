
#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "MNTPMathUtils.h"
#import "MNTPSubmesh.h"

NS_ASSUME_NONNULL_BEGIN


@interface MNTPMesh : NSObject

@property (nonatomic, readonly, nonnull) struct MNTPVertexData *vertexBuffer;

@property (nonatomic, readonly) NSUInteger vertexCount;

@property (nonatomic, nonnull) NSString *name;

@property (nonatomic, copy) NSMutableArray<MNTPSubmesh *> *submeshes;

- (void)addVertex:(MNTPVertexData)vertex;

- (void)updateVertexArray:(MNTPVertexData *)vertexArray count:(NSInteger)vertexCount;

@end



NS_ASSUME_NONNULL_END
