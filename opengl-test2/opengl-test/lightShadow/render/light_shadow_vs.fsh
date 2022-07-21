
#version 300 es

in vec4 position;
in vec4 inputTextureCoordinate;
in vec3 aNormal;
in vec3 tangent;



uniform highp mat4 shadowMapMVP;

uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;

uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 viewPos;



out vec2 textureCoordinate;
out vec3 shadowMapTextureCoord;
out vec3 FragPos;

out vec3 FragPos_tbn;
out vec3 lightPos_tbn;
out vec3 viewPos_tbn;




void main()
{
    gl_Position = pMatrix * vMatrix * mMatrix * position;
    textureCoordinate = inputTextureCoordinate.xy;
    
    highp vec4  ass =  shadowMapMVP * position;
    shadowMapTextureCoord = vec3(ass.x / ass.w * 0.5 + 0.5,ass.y / ass.w * 0.5 + 0.5, ass.z / ass.w * 0.5 + 0.5);
    
    FragPos = vec3(mMatrix * position);

    
    /// 将 灯光位置 眼睛位置 片段位置 转换到TBN空间
//    vec3 T = normalize(tangent);
//    vec3 N = normalize(aNormal);
//    vec3 B = cross(T, N);
//    mat3 tbn = mat3(T,B,N);
//    mat3 inverseTBN = transpose(mat3(mMatrix) * tbn);
    
    vec3 T = normalize(vec3(mMatrix * vec4(tangent, 0.0)));
    vec3 N = normalize(vec3(mMatrix * vec4(aNormal, 0.0)));
    vec3 B = cross(T, N);
    mat3 TBN = mat3(T, B, N);
    mat3 inverseTBN = transpose(TBN);
    
    

    FragPos_tbn = inverseTBN * FragPos;
    lightPos_tbn = inverseTBN * lightPos;
    viewPos_tbn = inverseTBN * viewPos;
    
    
    
    
    
}



//     normal = mat3(transpose(inverse(mMatrix))) * aNormal;  对三角形进行了不等比例的缩放就要用到法线矩阵
//     normal = vec3(mMatrix * vec4(aNormal, 0.)); /// 将法线从模型空间转换到 世界空间


