
#include <metal_stdlib>

using namespace metal;

#include "AAPLShaderTypes.h"


// Vertex shader outputs and fragment shader inputs for simple pipeline 顶点着色器传给片段着色器 需要插值的数据
struct mipmapPipelineRasterizerData
{
    float4 position [[position]];
    float2 texcoord;
};

vertex mipmapPipelineRasterizerData
mipmapVertexShader(const uint vertexID [[ vertex_id ]],
                   const device AAPLTextureVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]])
{
    mipmapPipelineRasterizerData out;

    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = vertices[vertexID].position.xy;

    out.texcoord = vertices[vertexID].texcoord;
    return out;
}


fragment float4 mipmapFragmentShader(mipmapPipelineRasterizerData in [[stage_in]],
                                     texture2d<float>              texture [[texture(AAPLTextureInputIndexColor)]])
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, mip_filter::linear, min_filter::linear);
    /// GL_LINEAR_MIPMAP_LINEAR 对比 opengl mip_filter 对比前一段 min_filter 对比后一段 三线性插值效果更好
    
    float4 colorSample = texture.sample(simpleSampler, in.texcoord);
    
    return colorSample;
}

