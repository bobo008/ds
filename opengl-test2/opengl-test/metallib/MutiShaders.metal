
#include <metal_stdlib>

using namespace metal;

#include "AAPLShaderTypes.h"


// Vertex shader outputs and fragment shader inputs for simple pipeline 顶点着色器传给片段着色器 需要插值的数据
struct mutiPipelineRasterizerData
{
    float4 position [[position]];
    float2 texcoord;
};

struct GBufferData
{
    float4 ret1        [[color(0), raster_order_group(0)]];
    float4 ret2 [[color(1), raster_order_group(1)]];

};

vertex mutiPipelineRasterizerData
mutiVertexShader(const uint vertexID [[ vertex_id ]],
                   const device AAPLTextureVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]])
{
    mutiPipelineRasterizerData out;

    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = vertices[vertexID].position.xy;

    out.texcoord = vertices[vertexID].texcoord;
    return out;
}


fragment GBufferData mutiFragmentShader(mutiPipelineRasterizerData in [[stage_in]],
                                     texture2d<float>              texture [[texture(AAPLTextureInputIndexColor)]])
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);

    
    float4 colorSample = texture.sample(simpleSampler, in.texcoord);
    
    GBufferData out;
    out.ret1 = colorSample;
    out.ret2 = colorSample;
    return out;
}

