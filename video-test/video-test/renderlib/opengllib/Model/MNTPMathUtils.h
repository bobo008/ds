#import "AAPLMathUtilities.h"

#define MNTP_SIMD_OVERLOAD AAPL_SIMD_OVERLOAD

typedef struct MNTPVertexData {
    vector_float3 position;
    vector_float3 normal;
    vector_float2 texcoord;
} MNTPVertexData;

MNTPVertexData MNTP_SIMD_OVERLOAD MNTPVertexMake(vector_float3 pos, vector_float3 normal, vector_float2 texcoord);

simd_bool MNTP_SIMD_OVERLOAD MNTPVertexIsEqual(MNTPVertexData left, MNTPVertexData right);

/// 计算面 v1 -> v2 -> v3 -> v1 的法线
vector_float3 MNTP_SIMD_OVERLOAD MNTPGetNormal(vector_float3 v1, vector_float3 v2, vector_float3 v3);

float * MNTP_SIMD_OVERLOAD matrixData(matrix_float2x2 mat);
float * MNTP_SIMD_OVERLOAD matrixData(matrix_float3x3 mat);
float * MNTP_SIMD_OVERLOAD matrixData(matrix_float4x4 mat);

float MNTP_SIMD_OVERLOAD simd_normalized_clamp(float x, float min, float max);

vector_float3 MNTP_SIMD_OVERLOAD simd_make_rotation(matrix_float3x3 rotM, vector_float3 anchor, vector_float3 vec);
vector_double3 MNTP_SIMD_OVERLOAD simd_make_rotation(matrix_double3x3 rotM, vector_double3 anchor, vector_double3 vec);
vector_float3 MNTP_SIMD_OVERLOAD simd_get_normal(vector_float3 v1, vector_float3 v2, vector_float3 v3);
vector_double3 MNTP_SIMD_OVERLOAD simd_get_normal(vector_double3 v1, vector_double3 v2, vector_double3 v3);

#pragma mark - 一些精度转换
vector_float3 MNTP_SIMD_OVERLOAD get_float3_from_double(vector_double3 v);
vector_float2 MNTP_SIMD_OVERLOAD get_float2_from_double(vector_double2 v);
matrix_float4x3 MNTP_SIMD_OVERLOAD get_float4x3_from_double(matrix_double4x3 m);
matrix_float3x3 MNTP_SIMD_OVERLOAD get_float3x3_from_double(matrix_double3x3 m);
matrix_float4x2 MNTP_SIMD_OVERLOAD get_float4x2_from_double(matrix_double4x2 m);
matrix_float3x2 MNTP_SIMD_OVERLOAD get_float3x2_from_double(matrix_double3x2 m);
