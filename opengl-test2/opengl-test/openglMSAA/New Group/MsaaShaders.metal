
#include <metal_stdlib>

using namespace metal;

#include "MsaaShaderTypes.h"


// Vertex shader outputs and fragment shader inputs for simple pipeline 顶点着色器传给片段着色器 需要插值的数据
struct msaaPipelineRasterizerData
{
    float4 position [[position]];
    float2 texcoord;
};

vertex msaaPipelineRasterizerData
msaaVertexShader(const uint vertexID [[ vertex_id ]],
                   const device AAPLTextureVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]])
{
    msaaPipelineRasterizerData out;

    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = vertices[vertexID].position.xy;

    out.texcoord = vertices[vertexID].texcoord;
    return out;
}


fragment float4 msaaFragmentShader(msaaPipelineRasterizerData in [[stage_in]],
                                     texture2d<float>              texture [[texture(AAPLTextureInputIndexColor)]])
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);

    float4 colorSample = texture.sample(simpleSampler, in.texcoord);
    
    return colorSample;
}

