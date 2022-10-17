
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"


struct Vertex
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

// 这个类型只有使用多个 buffer 的时候才能使用，不然会出错！！
//vertex oneInputPipelineRasterizerData mvp3DProcessVertexShader(Vertex in [[stage_in]])
//{
//    
//    oneInputPipelineRasterizerData out;
//    float4 pos = float4(in.position, 1.0);
////    out.position = uniform.modelViewProjectionMatrix * pos;
//    out.position = pos;
//    out.texcoord = in.texCoord;
//    
//    return out;
//}




vertex oneInputPipelineRasterizerData mvp3DProcessVertexShader(uint vertexID [[ vertex_id]],
                                                               constant Vertex *vertexAttr [[buffer(0)]],
                                                               constant modelViewProjectionUniform & uniform [[ buffer(2) ]])
{
    
    oneInputPipelineRasterizerData out;
    float4 pos = float4(vertexAttr[vertexID].position, 1.0);
    out.position = uniform.modelViewProjectionMatrix * pos;
    out.texcoord = vertexAttr[vertexID].texCoord;
    
    return out;
}

fragment float4 mvp3DProcessFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                           float4   base [[color(0)]],
                                           texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    

    constexpr sampler simpleSampler (s_address::clamp_to_zero, t_address::clamp_to_zero, mag_filter::linear, min_filter::linear);
    float4 overlay = texture.sample(simpleSampler, in.texcoord);
    
    return base + overlay - base * overlay.a;
}










vertex oneInputPipelineRasterizerData mvp3DVertexShader(const uint vertexID [[ vertex_id ]],
                                                        const device PositionVertex3D *positions [[buffer(PPPVertexInputIndexPosition)]],
                                                        const device TexcoordVertex *texcoords [[buffer(PPPVertexInputIndexTexcoord)]],
                                                        constant modelViewProjectionUniform & uniform [[ buffer(3) ]])
{
    oneInputPipelineRasterizerData out;
    
    float4 pos = positions[vertexID].position;
    
    out.position = uniform.modelViewProjectionMatrix * pos;
    
    out.texcoord = texcoords[vertexID].texcoord;
    return out;
}






fragment float4 mvp3DFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                    texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
    
    float4 colorSample = texture.sample(simpleSampler, in.texcoord);
    
    return colorSample;
}

