
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"



float4 lookup(float4 color, texture2d<float> texture1, sampler simpleSampler) {
    float blueColor = color.b * 63.0;
    
    float2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    
    float2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    float2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * color.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * color.g);
    
    float2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * color.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * color.g);
    
    float4 newColor1 = texture1.sample(simpleSampler, texPos1);
    float4 newColor2 = texture1.sample(simpleSampler, texPos2);
    
    float4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return newColor;
}



fragment float4 lutFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                  texture2d<float> texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                  texture2d<float> texture1 [[texture(PPPTextureInputIndexTexture1)]],
                                  constant float & intensity [[ buffer(0)]]
                                  )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
    
    
    
    float4 textureColor = texture0.sample(simpleSampler, in.texcoord);
    if (textureColor.a > 0.) {
        float4 unpremulTextureColor = textureColor / textureColor.a;
        float4 newColor = lookup(unpremulTextureColor, texture1, simpleSampler);
        return mix(unpremulTextureColor, newColor, intensity) * textureColor.a;
    } else {
        return textureColor;
    }
    
}

