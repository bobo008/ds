attribute vec4 position;
attribute vec4 inputTextureCoordinate;
attribute vec3 aNormal;


varying vec3 normal;
varying vec2 textureCoordinate;
varying vec3 FragPos;


uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;
uniform highp mat4 TBN;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 viewPos;


varying vec3 FragPos_tbn;
varying vec3 lightPos_tbn;
varying vec3 viewPos_tbn;

void main()
{
    gl_Position = pMatrix * vMatrix * mMatrix * position;
    textureCoordinate = inputTextureCoordinate.xy;
    
    FragPos = vec3(mMatrix * position);
    
    
    
    
    

    /// 将 灯光位置 眼睛位置 片段位置 转换到TBN空间
//    mat3 inverseTBN = inverse(mat3(mMatrix * TBN));
    
    mat3 inverseTBN = mat3(TBN);
    FragPos_tbn = inverseTBN * FragPos;
    lightPos_tbn = inverseTBN * lightPos;
    viewPos_tbn = inverseTBN * viewPos;

    
    
//     normal = mat3(transpose(inverse(mMatrix))) * aNormal;  对三角形进行了不等比例的缩放就要用到法线矩阵
//    normal = vec3(mMatrix * vec4(aNormal, 0.)); /// 将法线从模型空间转换到 世界空间
}
