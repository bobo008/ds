

precision highp float;
precision mediump int;

varying highp vec2 textureCoordinate;
varying vec3 normal2;// 具备发现贴图以后这个normal就失效了
varying vec3 FragPos;


uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec3 lightPos;
uniform vec3 viewPos;


uniform highp mat4 pMatrix;
uniform highp mat4 vMatrix;
uniform highp mat4 mMatrix;



vec4 getAmbient(vec4 objectColor) {
    float ambientStrength = 0.1;
    vec4 ambient = ambientStrength * vec4(1.0);/// vec4(1.0) 是light 颜色
    
    vec4 result = ambient * objectColor;
    return result;
}

vec4 getDiffes(vec4 objectColor, vec3 normal) {
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec4 diffuse = diff * vec4(1.0);
    
    vec4 result = diffuse * objectColor;
    return result;
}

vec4 getSpecula(vec4 objectColor, vec3 normal) {
    float specularStrength = 0.5;
    
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    
    vec3 viewDir = normalize(viewPos - FragPos);
    
    vec3 reflectDir = reflect(-lightDir, norm);
    
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.);
    
    vec4 specular = specularStrength * spec * vec4(1.0);
    
    vec4 result = specular * objectColor;
    return result;
}





void main() {
    vec4 objColor = texture2D(inputImageTexture, textureCoordinate);
    vec4 normal = texture2D(inputImageTexture2, textureCoordinate);
    vec3 normal2 = vec3(mMatrix * vec4(normal.rgb, 0.)); /// 当在世界空间做光照的时候，会遇到用了法线贴图的发现计算要放到片段着色器中，对性能是有影响的
    
    vec4 ret = getAmbient(objColor);
    vec4 ret2 = getDiffes(objColor, normal2);
    vec4 ret3 = getSpecula(objColor, normal2);
    
    gl_FragColor = ret + ret2 + ret3;
    //    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    
//    gl_FragColor = vec4(0.,0.,1.,1.);
}
