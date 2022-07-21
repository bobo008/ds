
#version 300 es

precision highp float;
precision mediump int;

in highp vec2 textureCoordinate;
in highp vec3 shadowMapTextureCoord;
in vec3 FragPos;
in vec3 FragPos_tbn;
in vec3 lightPos_tbn;
in vec3 viewPos_tbn;


uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform sampler2D inputImageTexture3;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform vec3 lightColor;

uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;


out vec4 FragColor;






vec3 getAmbient(vec4 objectColor) {
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;/// vec4(1.0) 是light 颜色
    return ambient;
}

vec3 getDiffes(vec4 objectColor, vec3 normal) {
    float diffuseStrength = 0.9;
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos_tbn - FragPos_tbn);
    
    float diff = max(dot(norm, lightDir), 0.0); /// 因为两者都是方向向量，点乘获取光线向量投射到法线上的分量 如果是负数则丢弃
    vec3 diffuse = diffuseStrength * diff * lightColor;

    return diffuse;
}

vec3 getSpecula(vec4 objectColor, vec3 normal) {
    float specularStrength = 0.5;
    
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos_tbn - FragPos_tbn); /// 灯光向量 指向灯光
    
    vec3 viewDir = normalize(viewPos_tbn - FragPos_tbn); /// 人眼向量 指向人眼
    
    vec3 reflectDir = reflect(-lightDir, norm); /// reflect 计算A 沿着 B 的反射向量
    
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.); /// 32 高光的反光度 越大则反射越强
    
    vec3 specular = specularStrength * spec * lightColor; /// 乘反射系数 灯光颜色
    
    return specular;
}






void main() {
    vec4 objColor = texture(inputImageTexture, textureCoordinate); /// 环境光和漫反射贴图一般共用 镜面光贴图可能用其他的
    vec4 normal = texture(inputImageTexture2, textureCoordinate);
    normal = normalize(normal * 2.0 - 1.0); /// 将 0 - 1的法线转换为-1 - 1 正常方向应该是 0.5 0.5 1
    
    
    
    vec3 normal2 = normal.rgb; /// TBN 空间计算光照只有在用到了法线贴图的时候才有意义，因为法线贴图要在片段着色器中将法线转换到世界空间，TBN可以在顶点着色器预防这个计算
    vec3 ret = getAmbient(objColor);
    vec3 ret2 = getDiffes(objColor, normal2);
    vec3 ret3 = getSpecula(objColor, normal2);
    FragColor = vec4((ret + ret2 + ret3) * objColor.xyz, 1.0);
    
    
    

    vec4 aaaa = texture(inputImageTexture3, shadowMapTextureCoord.xy);
    if (aaaa.a == 0.) {
        FragColor = vec4((ret + ret2 + ret3) * objColor.xyz, 1.0);
    } else if(aaaa.g - shadowMapTextureCoord.z < (1. / 255.) && aaaa.g - shadowMapTextureCoord.z > (-1. / 255.)) {/// 效果不太对劲，不应该用这个存，应该用每个比特存8位再读出来，精度太辣鸡
        FragColor = vec4((ret + ret2 + ret3) * objColor.xyz, 1.0);
    } else {
        FragColor = vec4(ret * objColor.xyz, 1.0);
    }
    
    

}
