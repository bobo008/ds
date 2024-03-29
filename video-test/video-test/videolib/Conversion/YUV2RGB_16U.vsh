
#version 300 es

layout(location = 0) in highp vec4 position;
layout(location = 1) in highp vec4 inputTextureCoordinate;

out vec2 textureCoordinate;

void main() {
    gl_Position = position;
    textureCoordinate = inputTextureCoordinate.xy;
}
