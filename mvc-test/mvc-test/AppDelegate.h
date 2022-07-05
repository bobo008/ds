//
//  AppDelegate.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@end



//
//使用切线空间
//为了解决前面的问题，我们需要使用切线空间。切线空间有两种方式可以得到正确的光照结果：
//
//将数据变换到 世界空间 来计算
//将数据变换到 切线空间 来计算
//很多人喜欢在世界空间中计算，因为将所有数据转换到世界空间再进行计算，是非常直观的，对于我们在讨论的问题也是如此。但这里我们使用第二种方式来计算，原因是它更高效。
//
//如果我们使用第一种方式，我们需要将每个从法线贴图中采样出来的法线变换到世界空间，这一步是在 片段着色器 中完成的，因为必须知道每个片段对应的的法线值，而不能简单的在顶点着色器中采样出来然后再插值到片段着色器中。如果我们使用第二种方式，我们会在 顶点着色器 中把所需要的数据，在这个例子中有平行光方向向量，顶点坐标，观察坐标（因为这个例子只有一个漫反射贴图，所以其实这个数据并没什么卵用）变换到切线空间，然后在片段着色器中只需要采样出法线向量，不需要再进行其他转换就可以直接进行计算了。而一般来说片段着色器执行的次数远大于顶点着色器执行的次数，所以第二种方式一般来说更高效。
//
//当然这里你可能有一个疑问，我们将一些数据从世界空间转换到切线空间，会涉及到矩阵的求逆，这一步是开销比较大的。理论上说，是的，但实际上，我们利用一个性质，即 正交矩阵的逆矩阵等于它的转置矩阵 就可以做到高效求逆矩阵，你在后面会看到。
//
//顶点 Shader
//首先我们将顶点数组传入顶点着色器，然后构造 TBN 矩阵 来把一些数据变换到切线空间，最后再传入到片段着色器里。我先列出顶点着色器中所需要的数据(除传入的顶点数据外，其余数据都是在世界空间下)：
//
//#version 330 core
//layout (location = 0) in vec3 vertexPosition; // 顶点坐标
//layout (location = 1) in vec3 vertexNormal; // 顶点法线
//layout (location = 2) in vec2 textureCoordinate; // 顶点纹理采样坐标
//layout (location = 3) in vec3 tangent; // 顶点切线
//layout (location = 4) in vec3 bitTangent; // 顶点副切线
//// 这是 OpenGL 中的 uniform 缓存，就是把一次渲染中不变的通用数据从外部代码传给 Shader
//layout (std140) uniform CameraInfo
//{
//    vec3 viewPosition; // 摄像机位置（观察位置）
//};
//// 平行光的数据
//struct DirectionalLight
//{
//    vec3 direction; // 方向
//    vec3 diffuseColor; // 漫反射颜色
//};
//uniform mat4 mvpMatrix;
//uniform mat4 modelMatrix;
//uniform DirectionalLight directionalLight;
//然后我们还需要定义输出给片段着色器的数据：
//
//out V_OUT
//{
//    vec2 textureCoordinate; // 纹理坐标
//    vec3 vertexPosition; // 切线空间顶点坐标
//    vec3 normal; // 发现向量
//    vec3 viewPosition; // 切线空间观察坐标
//    vec3 directionalLightDirection; // 切线空间平行光方向
//} v_out;
//这些数据定义好后，我们就可以着手编写转换各个数据到切线空间的代码了：
//
//void main()
//{
//    // 计算顶点的世界坐标
//    vec4 vertexPositionVector = vec4(vertexPosition, 1.f);
//    gl_Position = mvpMatrix * vertexPositionVector;
//
//    // 计算法线矩阵(这个矩阵可以使法线的坐标空间变换更精确，详细信息可以查阅【法线矩阵】 或 【Normal Transform】)
//    mat3 normalMatrix = transpose(inverse(mat3(modelMatrix)));
//    // 求 TBN 矩阵，三个向量均变换到世界空间
//    vec3 T = normalize(normalMatrix * tangent);
//    vec3 B = normalize(normalMatrix * bitTangent);
//    vec3 N = normalize(normalMatrix * vertexNormal);
//
//    // 求 TBN 矩阵的逆矩阵，因为 TBN 矩阵由三个互相垂直的单位向量组成，所以它是一个正交矩阵
//    // 正如前面所说，正交矩阵的逆矩阵等于它的转置，所以无需真的求逆矩阵
//    // 详情可查阅 【正交矩阵】 或 【Orthogonal Matrix】
//    mat3 inverseTBN = transpose(mat3(T, B, N));
//
//    // 将一些数据从世界空间变换到切线空间（并非所有数据都需要变换），然后传给片段着色器
//    v_out.directionalLightDirection = inverseTBN * directionalLight.direction;
//    v_out.vertexPosition = inverseTBN * vec3(gl_Position);
//    v_out.viewPosition = inverseTBN * viewPosition;
//    v_out.textureCoordinate = textureCoordinate;
//    v_out.normal = N;
//}
//写到这里我发现，我本来想只放出 Shader 片段的，但最后还是把整个顶点着色器的代码都写上了。我在里面添加了详细的注释，应该不会有什么很困惑的地方。
//
//片段 Shader
//由于我们将数据都变换到了切线空间下，那么片段着色器在计算的时候就方便多了，因为它们都在同一个空间下了。同样我们先定义所需要的数据：
//
//#version 330 core
//out vec4 f_color; // 输出的颜色
//// 这个跟顶点着色器中的 out 一致
//in V_OUT
//{
//    vec2 textureCoordinate;
//    vec3 vertexPosition;
//    vec3 normal;
//    vec3 viewPosition;
//    vec3 directionalLightDirection;
//} v_out;
//struct Material
//{
//    sampler2D diffuseTexture; // 漫反射贴图
//    sampler2D normalTexture; // 法线贴图
//};
//// 跟顶点着色器中的一致
//struct DirectionalLight
//{
//    vec3 direction;
//    vec3 diffuseColor;
//};
//uniform Material material; // 材质
//uniform DirectionalLight directionalLight; // 平行光信息
//最后计算最终的颜色：
//
//vec3 viewDirection; // 观察方向
//vec3 CaculateDiractionalLightColor()
//{
//    // 从法线贴图中采样出数据，并转换成法线值
//    // 转过算法为：贴图中存储 0 到 1 的值，而法线值是 -1 到 1
//    vec3 normal = vec3(texture(material.normalTexture, v_out.textureCoordinate));
//    normal = normalize(normal * 2.0 - 1.0);
//
//    // 计算漫反射
//    float diffuseRatio = max(dot(-v_out.directionalLightDirection, normal), 0.0);
//    vec3 diffuseColor = directionalLight.diffuseColor * diffuseRatio * vec3(texture(material.diffuseTexture0, v_out.textureCoordinate));
//
//    // 因为这个例子只用了漫反射贴图和法线贴图，所以其余如镜面反射或者环境光等就不计算了
//    return diffuseColor;
//}
//void main()
//{
//    viewDirection = normalize(v_out.vertexPosition - v_out.viewPosition);
//    f_color = vec4(CaculateDiractionalLightColor(), 1.0); // 输出最终颜色
//}
