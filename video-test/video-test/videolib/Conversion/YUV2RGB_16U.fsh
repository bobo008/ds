
#version 300 es

in highp vec2 textureCoordinate;

layout(location = 0) out highp vec4 finalColor;

uniform highp usampler2D luminanceTexture;
uniform highp usampler2D chrominanceTexture;
uniform highp mat3 colorConversionMatrix;
uniform highp vec3 colorConversionBias;

void main() {
    highp vec3 yuv = vec3(float(texture(luminanceTexture, textureCoordinate).r), vec2(texture(chrominanceTexture, textureCoordinate).rg)) / 65535.0;
    finalColor = vec4(colorConversionMatrix * (yuv - colorConversionBias), 1.0);
}
