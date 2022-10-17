
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"




// 需要切换 sampler 的时候就需要考虑传 sampler 进来了
//fragment float4 orientationFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
//                                           sampler  exampleSampler  [[sampler(0)]],
//                                           texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
//{
//
////    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
//
//    float4 colorSample = texture.sample(exampleSampler, in.texcoord);
//
//    return colorSample;
//}

fragment float4 orientationFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                          texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
    
    float4 colorSample = texture.sample(simpleSampler, in.texcoord);
    
    return colorSample;
}

