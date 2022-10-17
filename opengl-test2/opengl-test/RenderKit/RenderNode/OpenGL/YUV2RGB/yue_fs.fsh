#version 300 es

in highp vec2 textureCoordinate;

layout(location = 0) out mediump vec4 finalColor;

uniform sampler2D luminanceTexture;
uniform sampler2D chrominanceTexture;
uniform mediump mat3 colorConversionMatrix;

void main() {
    mediump vec3 yuv;
    mediump vec3 rgb;
    
    yuv.x = texture(luminanceTexture, textureCoordinate).r - (16.0/255.0);
    yuv.yz = texture(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
    rgb = colorConversionMatrix * yuv;
//    mediump float a = texture(luminanceTexture, textureCoordinate).r;
    finalColor = vec4(rgb, 1.0);
}
