

precision highp float;
precision mediump int;

varying highp vec2 textureCoordinate;
varying vec3 normal2;// 具备发现贴图以后这个normal就失效了
varying vec3 FragPos;


uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform vec3 lightColor;

uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;




varying vec3 FragPos_tbn;
varying vec3 lightPos_tbn;
varying vec3 viewPos_tbn;




vec4 getAmbient(vec4 objectColor) {
    float ambientStrength = 0.1;
    vec4 ambient = ambientStrength * vec4(lightColor,1.0);/// vec4(1.0) 是light 颜色
    return ambient;
}

vec4 getDiffes(vec4 objectColor, vec3 normal) {
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos_tbn - FragPos_tbn);
    
    float diff = max(dot(norm, lightDir), 0.0); /// 因为两者都是方向向量，点乘获取光线向量投射到法线上的分量 如果是负数则丢弃
    vec4 diffuse = diff * vec4(lightColor,1.0);

    return diffuse;
}

vec4 getSpecula(vec4 objectColor, vec3 normal) {
    float specularStrength = 0.5;
    
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos_tbn - FragPos_tbn); /// 灯光向量 指向灯光
    
    vec3 viewDir = normalize(viewPos_tbn - FragPos_tbn); /// 人眼向量 指向人眼
    
    vec3 reflectDir = reflect(-lightDir, norm); /// reflect 计算A 沿着 B 的反射向量
    
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.); /// 32 高光的反光度 越大则反射越强
    
    vec4 specular = specularStrength * spec * vec4(lightColor,1.0); /// 乘反射系数 灯光颜色
    
    return specular;
}





void main() {
    vec4 objColor = texture2D(inputImageTexture, textureCoordinate); /// 环境光和漫反射贴图一般共用 镜面光贴图可能用其他的
    vec4 normal = texture2D(inputImageTexture2, textureCoordinate);
    normal = normalize(normal * 2.0 - 1.0); /// 将 0 - 1的法线转换为-1 - 1 正常方向应该是 0.5 0.5 1
    
//    vec3 normal2 = vec3(mMatrix * vec4(normal.rgb, 0.)); /// 当在世界空间做光照的时候，会遇到用了法线贴图的发现计算要放到片段着色器中，对性能是有影响的
    vec3 normal2 = normal.rgb; /// TBN 空间计算光照只有在用到了法线贴图的时候才有意义，因为法线贴图要在片段着色器中将法线转换到世界空间，TBN可以在顶点着色器预防这个计算

    vec4 ret = getAmbient(objColor);
    vec4 ret2 = getDiffes(objColor, normal2);
    vec4 ret3 = getSpecula(objColor, normal2);
    
    gl_FragColor = (ret + ret2 + ret3) * objColor;
    
    
    
//    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
//    gl_FragColor = vec4(0.5,0.5,1.,1.);
}
