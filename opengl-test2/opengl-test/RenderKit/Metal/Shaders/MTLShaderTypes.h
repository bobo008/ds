
#ifndef MTLShaderTypes_h
#define MTLShaderTypes_h


#include <simd/simd.h>



typedef enum PPPVertexInputIndex
{
    PPPVertexInputIndexPosition = 0,
    PPPVertexInputIndexTexcoord = 1,
} PPPVertexInputIndex;

typedef enum PPPTextureInputIndex
{
    PPPTextureInputIndexTexture0 = 0,
    PPPTextureInputIndexTexture1 = 1,
    PPPTextureInputIndexTexture2 = 2,
    PPPTextureInputIndexTexture3 = 3,
} PPPTextureInputIndex;



typedef struct
{
    vector_float2 position;
    vector_float2 texcoord;
} PPPPosTexVertex_2; // 测试用




typedef struct
{
    vector_float3 position;
    vector_float2 texcoord;
} PPPPosTexVertex;





typedef struct
{
    vector_float2 position;
} PositionVertex;


typedef struct
{
    vector_float2 texcoord;
} TexcoordVertex;



typedef struct
{
    vector_float4 position;
} PositionVertex3D;


typedef struct
{
    matrix_float3x3 colorConversionMatrix;
} colorConversionUniform;



typedef struct
{
    matrix_float4x4 modelViewProjectionMatrix;
} modelViewProjectionUniform;





#endif /* MTLShaderTypes_h */


#if __METAL_MACOS__ || __METAL_IOS__

#include <metal_stdlib>

typedef struct
{
    float4 position [[position]];
    float2 texcoord;
} oneInputPipelineRasterizerData;



#endif
