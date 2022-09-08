
#version 300 es

in highp vec2 textureCoordinate;

layout(location = 0) out highp vec4 finalColor;

uniform sampler2D luminanceTexture;
uniform sampler2D chrominanceTexture;
uniform highp mat3 colorConversionMatrix;
uniform highp vec3 colorConversionBias;

void main() {
    highp vec3 yuv = vec3(texture(luminanceTexture, textureCoordinate).r, texture(chrominanceTexture, textureCoordinate).rg);
    finalColor = vec4(colorConversionMatrix * (yuv - colorConversionBias), 1.0);
}
