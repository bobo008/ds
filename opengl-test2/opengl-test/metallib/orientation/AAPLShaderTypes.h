
#ifndef AAPLShaderTypes_h
#define AAPLShaderTypes_h

#include <simd/simd.h>

typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices    = 0,
    AAPLVertexInputIndexAspectRatio = 1,
} AAPLVertexInputIndex;

typedef enum AAPLTextureInputIndex
{
    AAPLTextureInputIndexColor = 0,
} AAPLTextureInputIndex;


typedef struct
{
    vector_float2 position;
    vector_float2 texcoord;
} AAPLTextureVertex;

#endif /* AAPLShaderTypes_h */
