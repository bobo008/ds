
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"




float2 fixCoor(float2 coor) {
    coor.x = min(1., max(0., coor.x));
    coor.y = min(1., max(0., coor.y));
    return coor;
}



fragment float4 dilateHFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                      texture2d<float> texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                      constant float2 &iResolution     [[buffer(0)]],
                                      constant int & kernel2 [[ buffer(1)]],
                                      constant int & typeDilateOrErode [[ buffer(2)]]
                                      )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
    
    
    
    float2 normCoor = in.texcoord;
    float2 regularCoor = normCoor * iResolution.xy;
    int len = kernel2 / 2;
    float selectColor;
    if (typeDilateOrErode == 0) {
        selectColor = 0.;
    } else {
        selectColor = 1.;
    }
    for(int col = -len; col <= len; col++) {
        normCoor = float2(regularCoor.x + float(col), regularCoor.y) / iResolution.xy;
        normCoor = fixCoor(normCoor);
        
        float4 color = texture0.sample(simpleSampler, normCoor);
        if (typeDilateOrErode == 0) {
            selectColor = max(selectColor, color.x);
        } else {
            selectColor = min(selectColor, color.x);
        }
    }
    return float4(selectColor, selectColor, selectColor, 1.);
    
}


fragment float4 dilateVFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                      texture2d<float> texture0 [[texture(PPPTextureInputIndexTexture0)]],
                                      constant float2 &iResolution     [[buffer(0)]],
                                      constant int & kernel2 [[ buffer(1)]],
                                      constant int & typeDilateOrErode [[ buffer(2)]]
                                      )
{
    
    constexpr sampler simpleSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
    
    
    
    float2 normCoor = in.texcoord;
    float2 regularCoor = normCoor * iResolution.xy;
    int len = kernel2 / 2;
    float selectColor;
    if (typeDilateOrErode == 0) {
        selectColor = 0.;
    } else {
        selectColor = 1.;
    }
    for(int col = -len; col <= len; col++) {
        normCoor = float2(regularCoor.x, regularCoor.y + float(col)) / iResolution.xy;
        normCoor = fixCoor(normCoor);
        
        float4 color = texture0.sample(simpleSampler, normCoor);
        if (typeDilateOrErode == 0) {
            selectColor = max(selectColor, color.x);
        } else {
            selectColor = min(selectColor, color.x);
        }
    }
    return float4(selectColor, selectColor, selectColor, 1.);
    
}
