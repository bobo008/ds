
#import "MNTPMesh.h"
#import "MNTPSubmesh.h"



#import <vector>

@implementation MNTPMesh
{
    std::vector<MNTPVertexData> _vertices;
}

- (NSMutableArray<MNTPSubmesh *> *)submeshes {
    if (!_submeshes) {
        _submeshes = [NSMutableArray array];
    }
    return _submeshes;
}

- (NSUInteger)vertexCount {
   return _vertices.size();
}

- (nonnull MNTPVertexData *)vertexBuffer {
    return &_vertices[0];
}

- (void)addVertex:(MNTPVertexData)vertex {
//    const MNTPVertexData &v = vertex;
    _vertices.push_back(vertex);
}

- (void)updateVertexArray:(MNTPVertexData *)vertexArray count:(NSInteger)vertexCount {
    _vertices.resize(vertexCount);
    std::copy(vertexArray, vertexArray + vertexCount, _vertices.begin());
}

@end
