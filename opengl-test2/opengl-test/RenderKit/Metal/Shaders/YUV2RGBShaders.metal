
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"









//fragment float4 yuv2rgbFragmentShader(oneInputPipelineRasterizerData222 in [[stage_in]],
//                                     texture2d<float>              texture0 [[texture(PPPTextureInputIndexTexture0)]],
//                                     texture2d<float>              texture1 [[texture(PPPTextureInputIndexTexture1)]],
//                                     constant float3x3& colorConversionMatrix [[ buffer(0) ]]
//                                     )
//{
//
//    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
//
//    float3 yuv;
//    float3 rgb;
//
//
//    yuv.x = texture0.sample(simpleSampler, in.texcoord).r;
//
//    yuv.yz = texture1.sample(simpleSampler, in.texcoord).rg - vector_float2(0.5, 0.5);
//    rgb = colorConversionMatrix * yuv;
//    float4 finalColor = vector_float4(rgb, 1.0);
//
//    return finalColor;
//}



// 因为这个是逐像素的计算，不会改size等 所以用 nearest 更合适，或多或少能减点性能，同时取到的色值也是最正确的
fragment float4 yuv2rgbFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                      texture2d<float>              texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                      texture2d<float>              texture1 [[texture(PPPTextureInputIndexTexture1)]],
                                      constant float3x3& colorConversionMatrix [[buffer(0)]],
                                      constant float3 &colorConversionBias     [[buffer(1)]]
                                      )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
    
    float3 yuv;
    yuv.x = texture0.sample(simpleSampler, in.texcoord).r;
    yuv.yz = texture1.sample(simpleSampler, in.texcoord).rg;
    
    float3 rgb = colorConversionMatrix * (yuv - colorConversionBias);
    float4 finalColor = float4(rgb, 1.0);
    
    return finalColor;
}



fragment float4 yuv2rgb_16u_FragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                           texture2d<float>              texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                           texture2d<float>              texture1 [[texture(PPPTextureInputIndexTexture1)]],
                                           constant float3x3& colorConversionMatrix [[buffer(0)]],
                                           constant float3 &colorConversionBias     [[buffer(1)]]
                                           )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
    
    float3 yuv = vector_float3(texture0.sample(simpleSampler, in.texcoord).r, texture1.sample(simpleSampler, in.texcoord).rg) / 35535.0;
    
    float3 rgb = colorConversionMatrix * (yuv - colorConversionBias);
    float4 finalColor = vector_float4(rgb, 1.0);
    
    return finalColor;
}


