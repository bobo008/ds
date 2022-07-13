
#import "MNTP3DAsset.h"
#import "MNTP3DAssetLoader.h"

#import "MNTPMesh.h"
#import "MNTPSubmesh.h"

#import "GPUImageContext.h"

#import "MNTP3DObjCache.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation MNTP3DAsset
{
    GLuint _vao;
    GLuint _vbo;

    GLuint *_indexBuffers;
    GLuint *_indexBuffersCount;
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    MNTP3DAsset *asset = [MNTP3DObjCache getAssetForPath:url.path];
    if (asset) {
        return asset;
    }
    MNTP3DAssetLoader *loader = [[MNTP3DAssetLoader alloc] init];
    asset = [loader loadAssetAtURL:url error:error];
    if (asset) {
        [MNTP3DObjCache cacheAsset:asset withObjPath:url.path];
    }
    return asset;
}

- (void)dealloc {
    if (_bufferLoaded) {
        [self unloadBufferForGL];
    }
}

- (uint32_t)indexGLBufferAtIndex:(NSUInteger)index {
    if (index < self.mesh.submeshes.count) {
        return _indexBuffers[index];
    }
    
    NSAssert(NO, @"");
    return 0;
}

- (uint32_t)indexGLBufferCountAtIndex:(NSUInteger)index {
    if (index < self.mesh.submeshes.count) {
        return _indexBuffersCount[index];
    }
    
    NSAssert(NO, @"");
    return 0;
}

- (uint32_t)vertexGLBuffer {
    return _vao;
}

- (void)setMesh:(MNTPMesh *)mesh {
    [self unloadBufferForGL];
    _mesh = mesh;
}

- (void)loadBufferForGL {
    if (_bufferLoaded) {
        return;
    }
    
    MNTPMesh *meshData = _mesh;
    
    GLvoid *vertexData = meshData.vertexBuffer;
    NSUInteger dataSize = sizeof(MNTPVertexData) * meshData.vertexCount;
    
    [GPUImageContext useImageProcessingContext];
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, dataSize, vertexData, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(MNTPVertexData), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(MNTPVertexData), BUFFER_OFFSET(offsetof(MNTPVertexData, texcoord)));
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(MNTPVertexData), BUFFER_OFFSET(offsetof(MNTPVertexData, normal)));
    glEnableVertexAttribArray(2);
    
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    NSArray *submeshes = meshData.submeshes;
    
    _indexBuffers = (GLuint*)malloc(sizeof(GLuint) * submeshes.count);
    _indexBuffersCount = (GLuint*)malloc(sizeof(GLuint) * submeshes.count);
//    _textures = (GLuint*)malloc(sizeof(GLuint*) * _numOfSubmeshes);
    
    for (NSUInteger i = 0; i < submeshes.count; i++) {
        MNTPSubmesh *submeshData = submeshes[i];
        _indexBuffersCount[i] = (GLuint)submeshData.indexCount;

        NSUInteger indexBufferSize = sizeof(uint32_t) * submeshData.indexCount;

        GLuint indexBufferName;
        glGenBuffers(1, &indexBufferName);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferName);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexBufferSize, submeshData.indexBuffer, GL_STATIC_DRAW);

        _indexBuffers[i] = indexBufferName;
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    _bufferLoaded = YES;
}

- (void)unloadBufferForGL {
    if (!_bufferLoaded) {
        return;
    }
    
    [GPUImageContext useImageProcessingContext];
    
    glDeleteVertexArrays(1, &_vao);
    glDeleteBuffers(1, &_vbo);
    glDeleteBuffers((int)_mesh.submeshes.count, _indexBuffers);
    free(_indexBuffers);
    free(_indexBuffersCount);
    
    _bufferLoaded = NO;
}

- (void)bindBufferForGL {
    glBindVertexArray(_vao);
}

- (void)detachBufferForGL {
    glBindVertexArray(0);
}

@end

