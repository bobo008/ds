
#version 300 es

precision highp float;
precision mediump int;


in highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;



layout(location = 0) out vec4 FragColor1;
layout(location = 1) out vec4 FragColor2;

void main()
{
    FragColor1 = texture(inputImageTexture, textureCoordinate);
    
    FragColor2 = texture(inputImageTexture, textureCoordinate);
}
