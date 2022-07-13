#import "MNTPMathUtils.h"

MNTPVertexData MNTP_SIMD_OVERLOAD MNTPVertexMake(vector_float3 pos, vector_float3 normal, vector_float2 texcoord) {
    MNTPVertexData v;
    v.position = pos;
    v.normal = normal;
    v.texcoord = texcoord;
    return v;
};

simd_bool MNTP_SIMD_OVERLOAD MNTPVertexIsEqual(MNTPVertexData left, MNTPVertexData right) {
    return (simd_all(left.position == right.position) &&
            simd_all(left.normal == right.normal) &&
            simd_all(left.texcoord == right.texcoord));
};

vector_float3 MNTP_SIMD_OVERLOAD MNTPGetNormal(vector_float3 v1, vector_float3 v2, vector_float3 v3) {
    vector_float3 e1 = v2 - v1;
    vector_float3 e2 = v3 - v1;
    return simd_cross(e1, e2);
}

float * MNTP_SIMD_OVERLOAD matrixData(matrix_float2x2 mat) {
    float *m = malloc(4 * sizeof(float));
    m[0] = mat.columns[0].x;  m[2] = mat.columns[1].x;
    m[1] = mat.columns[0].y;  m[3] = mat.columns[1].y;
    return m;
}

float * MNTP_SIMD_OVERLOAD matrixData(matrix_float3x3 mat) {
    float *m = malloc(9 * sizeof(float));
    m[0] = mat.columns[0].x;  m[3] = mat.columns[1].x;  m[6] = mat.columns[2].x;
    m[1] = mat.columns[0].y;  m[4] = mat.columns[1].y;  m[7] = mat.columns[2].y;
    m[2] = mat.columns[0].z;  m[5] = mat.columns[1].z;  m[8] = mat.columns[2].z;
    return m;
}

float * MNTP_SIMD_OVERLOAD matrixData(matrix_float4x4 mat) {
    float *m = malloc(16 * sizeof(float));
    m[0] = mat.columns[0].x;  m[4] = mat.columns[1].x;  m[8]  = mat.columns[2].x;  m[12] = mat.columns[3].x;
    m[1] = mat.columns[0].y;  m[5] = mat.columns[1].y;  m[9]  = mat.columns[2].y;  m[13] = mat.columns[3].y;
    m[2] = mat.columns[0].z;  m[6] = mat.columns[1].z;  m[10] = mat.columns[2].z;  m[14] = mat.columns[3].z;
    m[3] = mat.columns[0].w;  m[7] = mat.columns[1].w;  m[11] = mat.columns[2].w;  m[15] = mat.columns[3].w;
    return m; 
}

float MNTP_SIMD_OVERLOAD simd_normalized_clamp(float x, float min, float max) {
    float r = simd_clamp(x, min, max);
    return (r - min) / (max - min);
}

vector_float3 MNTP_SIMD_OVERLOAD simd_make_rotation(matrix_float3x3 rotM, vector_float3 anchor, vector_float3 vec) {
    return matrix_multiply(rotM, vec - anchor) + anchor;
}

vector_double3 MNTP_SIMD_OVERLOAD simd_make_rotation(matrix_double3x3 rotM, vector_double3 anchor, vector_double3 vec) {
    return matrix_multiply(rotM, vec - anchor) + anchor;
}

vector_float3 MNTP_SIMD_OVERLOAD simd_get_normal(vector_float3 v1, vector_float3 v2, vector_float3 v3) {
    vector_float3 e1 = v2 - v1;
    vector_float3 e2 = v3 - v1;
    return simd_normalize(simd_cross(e1, e2));
}

vector_double3 MNTP_SIMD_OVERLOAD simd_get_normal(vector_double3 v1, vector_double3 v2, vector_double3 v3) {
    vector_double3 e1 = v2 - v1;
    vector_double3 e2 = v3 - v1;
    return simd_normalize(simd_cross(e1, e2));
}

#pragma mark - 一些精度转换
vector_float3 MNTP_SIMD_OVERLOAD get_float3_from_double(vector_double3 v) {
    return simd_make_float3((float)v[0], (float)v[1], (float)v[2]);
}

vector_float2 MNTP_SIMD_OVERLOAD get_float2_from_double(vector_double2 v) {
    return simd_make_float2((float)v[0], (float)v[1]);
}

matrix_float4x3 MNTP_SIMD_OVERLOAD get_float4x3_from_double(matrix_double4x3 m) {
    
    vector_float3 c0 = get_float3_from_double(m.columns[0]);
    vector_float3 c1 = get_float3_from_double(m.columns[1]);
    vector_float3 c2 = get_float3_from_double(m.columns[2]);
    vector_float3 c3 = get_float3_from_double(m.columns[3]);
    
    matrix_float4x3 matrix = {c0, c1, c2, c3};
    
    return matrix;
}

matrix_float3x3 MNTP_SIMD_OVERLOAD get_float3x3_from_double(matrix_double3x3 m) {
    
    vector_float3 c0 = get_float3_from_double(m.columns[0]);
    vector_float3 c1 = get_float3_from_double(m.columns[1]);
    vector_float3 c2 = get_float3_from_double(m.columns[2]);
    
    matrix_float3x3 matrix = {c0, c1, c2};
    
    return matrix;
}

matrix_float4x2 MNTP_SIMD_OVERLOAD get_float4x2_from_double(matrix_double4x2 m) {
    vector_float2 c0 = get_float2_from_double(m.columns[0]);
    vector_float2 c1 = get_float2_from_double(m.columns[1]);
    vector_float2 c2 = get_float2_from_double(m.columns[2]);
    vector_float2 c3 = get_float2_from_double(m.columns[3]);
    
    matrix_float4x2 matrix = {c0, c1, c2, c3};
    return matrix;
}

matrix_float3x2 MNTP_SIMD_OVERLOAD get_float3x2_from_double(matrix_double3x2 m) {
    vector_float2 c0 = get_float2_from_double(m.columns[0]);
    vector_float2 c1 = get_float2_from_double(m.columns[1]);
    vector_float2 c2 = get_float2_from_double(m.columns[2]);
    
    matrix_float3x2 matrix = {c0, c1, c2};
    return matrix;
}

