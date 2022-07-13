attribute vec4 position;
attribute vec4 inputTextureCoordinate;
attribute vec3 aNormal;


varying vec3 normal;
varying vec2 textureCoordinate;
varying vec3 FragPos;


uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;
uniform vec3 lightPos;
uniform vec3 viewPos;


void main()
{
    gl_Position = pMatrix * vMatrix * mMatrix * position;
    textureCoordinate = inputTextureCoordinate.xy;
    
    FragPos = vec3(mMatrix * position);
    
    //     normal = aNormal;
    
    //     normal = mat3(transpose(inverse(mMatrix))) * aNormal;  对三角形进行了不等比例的缩放就要用到法线矩阵
    normal = vec3(mMatrix * vec4(aNormal, 0.));
}
