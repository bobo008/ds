
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"






fragment float4 maskFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                   texture2d<float> texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                   texture2d<float> texture1 [[texture(PPPTextureInputIndexTexture1)]]//mask
                                   )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::linear);
    
    constexpr sampler simpleSampler2 (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
    
    float4 textureColor = texture0.sample(simpleSampler, in.texcoord);
    float4 maskColor = texture1.sample(simpleSampler2, in.texcoord);
    
    
    return textureColor * maskColor.b;
}



fragment float4 mergeFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                    texture2d<float> texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                    texture2d<float> texture1 [[texture(PPPTextureInputIndexTexture1)]], //mlResult
                                    texture2d<float> texture2 [[texture(PPPTextureInputIndexTexture2)]], //mask
                                    constant float4 &roiRect     [[buffer(0)]]
                                    )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::linear);
    constexpr sampler fineSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
    
    
    float2 texcoord = in.texcoord;
    
    if (texcoord.x <= roiRect.x || texcoord.y <= roiRect.y || texcoord.x >= roiRect.x + roiRect.z || texcoord.y >= roiRect.y + roiRect.w) {
        return texture0.sample(simpleSampler, in.texcoord);
    } else {

        float2 coorInROI = float2((texcoord.x - roiRect.x) / roiRect.z, (texcoord.y - roiRect.y) / roiRect.w); // in roi
        
        
        float4 srcColor = texture0.sample(simpleSampler, texcoord);
        float4 mlResultColor = texture1.sample(fineSampler, coorInROI);
        float4 maskColor = texture2.sample(fineSampler, coorInROI);
        
        float p = maskColor.r;
        
        return srcColor * (1. - p) + mlResultColor * p;
    }
    
}

