
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"





// 需要切换 sampler 的时候就需要考虑传 sampler 进来了
fragment float4 normalBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                          float4   base [[color(0)]],
                                          sampler  exampleSampler  [[sampler(0)]],
                                          texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return base + overlay - base * overlay.a;
}





fragment float4 multiplyBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                            float4   base [[color(0)]],
                                            sampler  exampleSampler  [[sampler(0)]],
                                            texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return (1.0 - overlay.a) * base + (1.0 - base.a) * overlay + base * overlay;
}





float3 hardlight(float4 base, float4 overlay) {
    float ra;
    if (2.0 * overlay.r < overlay.a) {
        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    }
    
    float ga;
    if (2.0 * overlay.g < overlay.a) {
        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    }
    
    float ba;
    if (2.0 * overlay.b < overlay.a) {
        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    }
    
    return float3(ra, ga, ba);
}


fragment float4 overlayBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                           float4   base [[color(0)]],
                                           sampler  exampleSampler  [[sampler(0)]],
                                           texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return float4(hardlight(overlay, base), base.a + overlay.a - base.a * overlay.a);
}


float eachcomponentPinLight(float Cb, float Cs) {
    if (Cs <= 0.5) {
        return min(2.0 * Cs, Cb);
    } else {
        return max(2.0 * (Cs - 0.5), Cb);
    }
}

fragment float4 pinLightBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                            float4   base [[color(0)]],
                                            sampler  exampleSampler  [[sampler(0)]],
                                            texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float r = eachcomponentPinLight(baseRGB.r, overlayRGB.r);
    float g = eachcomponentPinLight(baseRGB.g, overlayRGB.g);
    float b = eachcomponentPinLight(baseRGB.b, overlayRGB.b);
    float3 color = float3(r, g, b);
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
    
}






float lum(float3 c) {
    return dot(c, float3(0.3, 0.59, 0.11));
}

float3 clipcolor(float3 c) {
    float l = lum(c);
    float n = min(min(c.r, c.g), c.b);
    float x = max(max(c.r, c.g), c.b);
    
    if (n < 0.0) {
        c.r = l + ((c.r - l) * l) / (l - n);
        c.g = l + ((c.g - l) * l) / (l - n);
        c.b = l + ((c.b - l) * l) / (l - n);
    }
    if (x > 1.0) {
        c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
        c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
        c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
    }
    
    return c;
}

float3 setlum(float3 c, float l) {
    float d = l - lum(c);
    c = c + float3(d);
    return clipcolor(c);
}

float sat(float3 c) {
    float n = min(min(c.r, c.g), c.b);
    float x = max(max(c.r, c.g), c.b);
    return x - n;
}

float mid(float cmin, float cmid, float cmax, float s) {
    return ((cmid - cmin) * s) / (cmax - cmin);
}

float3 setsat(float3 c, float s) {
    if (c.r > c.g) {
        if (c.r > c.b) {
            if (c.g > c.b) {
                /* g is mid, b is min */
                c.g = mid(c.b, c.g, c.r, s);
                c.b = 0.0;
            } else {
                /* b is mid, g is min */
                c.b = mid(c.g, c.b, c.r, s);
                c.g = 0.0;
            }
            c.r = s;
        } else {
            /* b is max, r is mid, g is min */
            c.r = mid(c.g, c.r, c.b, s);
            c.b = s;
            c.g = 0.0;
        }
    } else if (c.r > c.b) {
        /* g is max, r is mid, b is min */
        c.r = mid(c.b, c.r, c.g, s);
        c.g = s;
        c.b = 0.0;
    } else if (c.g > c.b) {
        /* g is max, b is mid, r is min */
        c.b = mid(c.r, c.b, c.g, s);
        c.g = s;
        c.r = 0.0;
    } else if (c.b > c.g) {
        /* b is max, g is mid, r is min */
        c.g = mid(c.r, c.g, c.b, s);
        c.b = s;
        c.r = 0.0;
    } else {
        c = float3(0.0);
    }
    return c;
}




fragment float4 saturationBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                              float4   base [[color(0)]],
                                              sampler  exampleSampler  [[sampler(0)]],
                                              texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 color = setlum( setsat( baseRGB, sat(overlayRGB) ), lum(baseRGB) );
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
    
}


fragment float4 screenBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                          float4   base [[color(0)]],
                                          sampler  exampleSampler  [[sampler(0)]],
                                          texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return base + overlay - base * overlay;
    
}



float eachcomponentSoftLight(float Cb, float Cs) {
    if (Cs <= 0.5) {
        return Cb - (1.0 - 2.0 * Cs) * Cb * (1.0 - Cb);
    } else {
        float zeus = 0.0;
        if (Cb <= 0.25) {
            zeus = ((16.0 * Cb - 12.0) * Cb + 4.0) * Cb;
        } else {
            zeus = sqrt(Cb);
        }
        return Cb + (2.0 * Cs - 1.0) * (zeus - Cb);
    }
}


fragment float4 softLightBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                             float4   base [[color(0)]],
                                             sampler  exampleSampler  [[sampler(0)]],
                                             texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float r = eachcomponentSoftLight(baseRGB.r, overlayRGB.r);
    float g = eachcomponentSoftLight(baseRGB.g, overlayRGB.g);
    float b = eachcomponentSoftLight(baseRGB.b, overlayRGB.b);
    float3 color = clamp(float3(r, g, b), 0.0, 1.0);
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
    
}





fragment float4 subtractBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                            float4   base [[color(0)]],
                                            sampler  exampleSampler  [[sampler(0)]],
                                            texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 color = max(baseRGB - overlayRGB, 0.0);
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
    
    
}





float eachcomponentVividLight(float Cb, float Cs, float Ab, float As) {
    float nonPremultiplyCb = Cb / (Ab + step(Ab, 0.0));
    float nonPremultiplyCs = Cs / (As + step(As, 0.0));
    
    if (nonPremultiplyCs <= 0.5) {
        if (nonPremultiplyCs == 0.0) {
            return 0.0;
        } else {
            return 1.0 - (1.0 - nonPremultiplyCb) / (2.0 * nonPremultiplyCs);
        }
    } else {
        if (nonPremultiplyCs == 1.0) {
            return 1.0;
        } else {
            return nonPremultiplyCb / (2.0 * (1.0 - nonPremultiplyCs));
        }
    }
}



fragment float4 vividLightBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                              float4   base [[color(0)]],
                                              sampler  exampleSampler  [[sampler(0)]],
                                              texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float r = eachcomponentVividLight(base.r, overlay.r, base.a, overlay.a);
    float g = eachcomponentVividLight(base.g, overlay.g, base.a, overlay.a);
    float b = eachcomponentVividLight(base.b, overlay.b, base.a, overlay.a);
    float3 color = clamp(float3(r, g, b), 0.0, 1.0);
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}







fragment float4 luminosityBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                              float4   base [[color(0)]],
                                              sampler  exampleSampler  [[sampler(0)]],
                                              texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 color = setlum( baseRGB, lum(overlayRGB) );
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}




fragment float4 linearLightBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                               float4   base [[color(0)]],
                                               sampler  exampleSampler  [[sampler(0)]],
                                               texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * clamp(baseRGB + 2.0 * overlayRGB - 1.0, 0.0, 1.0), base.a + overlay.a - base.a * overlay.a);
}



fragment float4 linearDodgeBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                               float4   base [[color(0)]],
                                               sampler  exampleSampler  [[sampler(0)]],
                                               texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 Cr = (1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * clamp(baseRGB + overlayRGB, 0.0, 1.0);
    return float4(Cr, base.a + overlay.a - base.a * overlay.a);
}



fragment float4 linearBurnBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                              float4   base [[color(0)]],
                                              sampler  exampleSampler  [[sampler(0)]],
                                              texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 Cr = (1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * clamp(baseRGB + overlayRGB - 1.0, 0.0, 1.0);
    return float4(Cr, base.a + overlay.a - base.a * overlay.a);
}

fragment float4 lighterBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                           float4   base [[color(0)]],
                                           sampler  exampleSampler  [[sampler(0)]],
                                           texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float baseSum = baseRGB.r * 0.299 + baseRGB.g * 0.587 + baseRGB.b * 0.114;
    float overlaySum = overlayRGB.r * 0.299 + overlayRGB.g * 0.587 + overlayRGB.b * 0.114;
    float3 color = overlaySum > baseSum ? overlayRGB : baseRGB;
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}



fragment float4 lightenBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                           float4   base [[color(0)]],
                                           sampler  exampleSampler  [[sampler(0)]],
                                           texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    return float4(max(overlay.rgb + (1.0 - overlay.a) * base.rgb, base.rgb + (1.0 - base.a) * overlay.rgb), base.a + overlay.a - base.a * overlay.a);
}








fragment float4 hueBlendFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                       float4   base [[color(0)]],
                                       sampler  exampleSampler  [[sampler(0)]],
                                       texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 color = setlum( setsat( overlayRGB, sat(baseRGB) ), lum(baseRGB) );
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}



fragment float4 hardMixFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                      float4   base [[color(0)]],
                                      sampler  exampleSampler  [[sampler(0)]],
                                      texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float plato = base.a * overlay.a;
    float3 color = step(plato, overlay.rgb * base.a + base.rgb * overlay.a) * (1.0 - step(plato, 0.0));
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}






fragment float4 hardLightFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                        float4   base [[color(0)]],
                                        sampler  exampleSampler  [[sampler(0)]],
                                        texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float ra;
    if (2.0 * overlay.r < overlay.a) {
        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    }
    
    float ga;
    if (2.0 * overlay.g < overlay.a) {
        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    }
    
    float ba;
    if (2.0 * overlay.b < overlay.a) {
        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    }
    
    return float4(ra, ga, ba, base.a + overlay.a - base.a * overlay.a);
}




fragment float4 exclusionFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                        float4   base [[color(0)]],
                                        sampler  exampleSampler  [[sampler(0)]],
                                        texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return float4(base.rgb + overlay.rgb - 2.0 * base.rgb * overlay.rgb, base.a + overlay.a - base.a * overlay.a);
}




fragment float4 divideFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                     float4   base [[color(0)]],
                                     sampler  exampleSampler  [[sampler(0)]],
                                     texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float odin = 1.0;
    if (base.a > 0.0) {
        odin = overlay.a / base.a;
    }
    
    float ra = 1.0 - step(base.r, 0.0);
    if (overlay.r > 0.0) {
        ra = base.r / overlay.r * odin;
    }
    
    float rg = 1.0 - step(base.g, 0.0);
    if (overlay.g > 0.0) {
        rg = base.g / overlay.g * odin;
    }
    
    float rb = 1.0 - step(base.b, 0.0);
    if (overlay.b > 0.0) {
        rb = base.b / overlay.b * odin;
    }
    
    float3 color = clamp(float3(ra, rg, rb), 0.0, 1.0);
    
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}




fragment float4 differenceFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                         float4   base [[color(0)]],
                                         sampler  exampleSampler  [[sampler(0)]],
                                         texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float3 Cr = (1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + abs(overlay.a * base.rgb - base.a * overlay.rgb);
    return float4(Cr, base.a + overlay.a - base.a * overlay.a);
}




fragment float4 darkerFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                     float4   base [[color(0)]],
                                     sampler  exampleSampler  [[sampler(0)]],
                                     texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float baseSum = baseRGB.r * 0.299 + baseRGB.g * 0.587 + baseRGB.b * 0.114;
    float overlaySum = overlayRGB.r * 0.299 + overlayRGB.g * 0.587 + overlayRGB.b * 0.114;
    float3 color = overlaySum < baseSum ? overlayRGB : baseRGB;
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
}






fragment float4 darkenFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                     float4   base [[color(0)]],
                                     sampler  exampleSampler  [[sampler(0)]],
                                     texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    return float4(min(overlay.rgb * base.a, base.rgb * overlay.a) + overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a), base.a + overlay.a - base.a * overlay.a);
}



fragment float4 colorDodgeFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                         float4   base [[color(0)]],
                                         sampler  exampleSampler  [[sampler(0)]],
                                         texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float3 baseOverlayAlphaProduct = float3(overlay.a * base.a);
    float3 rightHandProduct = overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a);
    float3 firstBlendColor = baseOverlayAlphaProduct + rightHandProduct;
    float3 overlayRGB = clamp((overlay.rgb / clamp(overlay.a, 0.01, 1.0)) * step(0.0, overlay.a), 0.0, 0.99);
    float3 secondBlendColor = (base.rgb * overlay.a) / (1.0 - overlayRGB) + rightHandProduct;
    float3 colorChoice = step((overlay.rgb * base.a + base.rgb * overlay.a), baseOverlayAlphaProduct);
    float3 Cr = mix(firstBlendColor, secondBlendColor, colorChoice);
    return float4(Cr, base.a + overlay.a - base.a * overlay.a);
}





fragment float4 colorBurnFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                        float4   base [[color(0)]],
                                        sampler  exampleSampler  [[sampler(0)]],
                                        texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    float4 Cb = base;
    float4 Cs = overlay;
    
    float CbCsAlphaProduct = Cb.a * Cs.a;
    
    float ra;
    if (Cs.r == 0.0) {
        ra = 0.0;
    } else {
        ra = CbCsAlphaProduct - min(CbCsAlphaProduct, (CbCsAlphaProduct * Cs.a - Cb.r * Cs.a * Cs.a) / Cs.r);
    }
    
    float rg;
    if (Cs.g == 0.0) {
        rg = 0.0;
    } else {
        rg = CbCsAlphaProduct - min(CbCsAlphaProduct, (CbCsAlphaProduct * Cs.a - Cb.g * Cs.a * Cs.a) / Cs.g);
    }
    
    float rb;
    if (Cs.b == 0.0) {
        rb = 0.0;
    } else {
        rb = CbCsAlphaProduct - min(CbCsAlphaProduct, (CbCsAlphaProduct * Cs.a - Cb.b * Cs.a * Cs.a) / Cs.b);
    }
    
    return float4((1.0 - Cs.a) * Cb.rgb + (1.0 - Cb.a) * Cs.rgb + float3(ra, rg, rb), Cb.a + Cs.a - Cb.a * Cs.a);
}






fragment float4 colorFragmentShader(oneInputPipelineRasterizerData in [[stage_in]],
                                    float4   base [[color(0)]],
                                    sampler  exampleSampler  [[sampler(0)]],
                                    texture2d<float> texture [[texture(PPPTextureInputIndexTexture0)]])
{
    
    float4 overlay = texture.sample(exampleSampler, in.texcoord);
    
    
    float3 baseRGB = base.rgb / (base.a + step(base.a, 0.0));
    float3 overlayRGB = overlay.rgb / (overlay.a + step(overlay.a, 0.0));
    float3 color = setlum( overlayRGB, lum(baseRGB) );
    return float4((1.0 - overlay.a) * base.rgb + (1.0 - base.a) * overlay.rgb + base.a * overlay.a * color, base.a + overlay.a - base.a * overlay.a);
    
}


